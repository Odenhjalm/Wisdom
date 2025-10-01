// deno-lint-ignore-file no-explicit-any
import Stripe from "https://esm.sh/stripe@12.16.0?target=deno";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  if (req.method !== 'POST') return new Response('Method Not Allowed', { status: 405 });
  const secret = Deno.env.get('STRIPE_SECRET_KEY');
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
  if (!secret || !webhookSecret) return new Response('Not configured', { status: 500 });
  const stripe = new Stripe(secret, { apiVersion: '2024-06-20' });

  const sig = req.headers.get('stripe-signature');
  const rawBody = await req.text();
  let event: any;
  try {
    event = stripe.webhooks.constructEvent(rawBody, sig!, webhookSecret);
  } catch (err) {
    return new Response(`Webhook Error: ${String(err)}`, { status: 400 });
  }

  try {
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as any;
      await handleCheckoutCompleted(session);
    }
  } catch (e) {
    console.error('stripe_webhook handler error', e);
    return new Response(`Handler error: ${String(e)}`, { status: 500 });
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});

async function handleCheckoutCompleted(session: any) {
  const orderId = session?.metadata?.order_id || session?.payment_intent?.metadata?.order_id;
  const paymentIntent = session.payment_intent as string | undefined;
  const checkoutId = session.id as string | undefined;
  if (!orderId || !paymentIntent) {
    console.warn('checkout.session.completed missing order metadata', {
      orderId,
      paymentIntent,
    });
    return;
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceKey) {
    throw new Error('Supabase env vars not configured');
  }
  const sb = createClient(supabaseUrl, serviceKey);

  const { error: rpcError } = await sb.rpc('app.complete_order', {
    p_order_id: orderId,
    p_payment_intent: paymentIntent,
    p_checkout_id: checkoutId,
  });
  if (rpcError) {
    throw rpcError;
  }

  const { data: orderRow, error: orderErr } = await sb
    .from('app.orders')
    .select('id, user_id, course_id, amount_cents, currency, status')
    .eq('id', orderId)
    .maybeSingle();
  if (orderErr) throw orderErr;
  if (!orderRow) {
    console.warn('Order row not found after completion', { orderId });
    return;
  }

  let buyerEmail: string | null = session?.customer_details?.email
    || session?.customer_email
    || session?.metadata?.buyer_email
    || null;

  if (!buyerEmail && orderRow.user_id) {
    const { data: profileRow } = await sb
      .from('app.profiles')
      .select('email')
      .eq('user_id', orderRow.user_id)
      .maybeSingle();
    buyerEmail = (profileRow as { email?: string } | null)?.email ?? null;
  }

  await upsertPurchase(sb, {
    orderId,
    orderRow,
    checkoutId,
    paymentIntent,
    buyerEmail,
  });
}

async function upsertPurchase(
  sb: ReturnType<typeof createClient>,
  args: {
    orderId: string;
    orderRow: any;
    checkoutId?: string;
    paymentIntent: string;
    buyerEmail: string | null;
  },
) {
  const { orderId, orderRow, checkoutId, paymentIntent, buyerEmail } = args;

  if (!buyerEmail) {
    console.warn('Skipping purchase insert – buyer email missing', { orderId });
    return;
  }

  const insertPayload: Record<string, unknown> = {
    order_id: orderId,
    stripe_checkout_id: checkoutId,
    stripe_payment_intent: paymentIntent,
    status: 'succeeded',
    user_id: orderRow.user_id,
    buyer_email: buyerEmail ?? undefined,
    course_id: orderRow.course_id,
    amount_cents: orderRow.amount_cents,
    currency: orderRow.currency,
  };

  try {
    const { data: purchaseRow, error: insertErr } = await sb
      .from('app.purchases')
      .upsert(insertPayload, { onConflict: 'stripe_checkout_id' })
      .select('id, user_id, course_id')
      .maybeSingle();
    if (insertErr) throw insertErr;
    if (!purchaseRow) return;

    if (!purchaseRow.user_id && purchaseRow.course_id && buyerEmail) {
      await handleGuestClaim(sb, {
        purchaseId: purchaseRow.id as string,
        courseId: purchaseRow.course_id as string,
        buyerEmail,
      });
    }
  } catch (err) {
    if (isRelationMissing(err)) {
      console.log('app.purchases missing – skipping purchase insert');
      return;
    }
    throw err;
  }
}

async function handleGuestClaim(
  sb: ReturnType<typeof createClient>,
  { purchaseId, courseId, buyerEmail }: { purchaseId: string; courseId: string; buyerEmail: string },
) {
  const { data: tokenRow, error } = await sb
    .from('app.guest_claim_tokens')
    .insert({
      buyer_email: buyerEmail,
      course_id: courseId,
      purchase_id: purchaseId,
    })
    .select('token')
    .maybeSingle();
  if (error) throw error;
  if (!tokenRow) return;

  await sendClaimEmail({
    email: buyerEmail,
    claimToken: tokenRow.token as string,
  });
}

async function sendClaimEmail({ email, claimToken }: { email: string; claimToken: string }) {
  const apiKey = Deno.env.get('RESEND_API_KEY');
  const from = Deno.env.get('RESEND_FROM_EMAIL');
  const siteUrl = Deno.env.get('SITE_URL') ?? 'https://visdom.app';
  const claimUrl = `${siteUrl.replace(/\/$/, '')}/claim?token=${claimToken}`;

  if (!apiKey || !from) {
    console.log('Skipping claim email – RESEND configuration missing', { email, claimUrl });
    return;
  }

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from,
      to: [email],
      subject: 'Få tillgång till din kurs',
      html: `
        <p>Hej!</p>
        <p>Tack för ditt köp. Klicka på länken nedan för att skapa ett konto eller logga in och få tillgång till din kurs.</p>
        <p><a href="${claimUrl}">${claimUrl}</a></p>
        <p>Om du inte gjort köpet kan du ignorera mailet.</p>
      `,
    }),
  });

  if (!res.ok) {
    const text = await res.text();
    console.error('Failed to send claim email', text);
  }
}

function isRelationMissing(error: unknown) {
  if (!error || typeof error !== 'object') return false;
  const message = (error as { message?: string }).message;
  return Boolean(message && /relation "app\.purchases" does not exist/i.test(message));
}
