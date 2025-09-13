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
      const orderId = session?.metadata?.order_id || session?.payment_intent?.metadata?.order_id;
      const paymentIntent = session.payment_intent as string | undefined;
      const checkoutId = session.id as string;
      if (orderId && paymentIntent) {
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
        const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
        const sb = createClient(supabaseUrl, serviceKey);
        await sb.rpc('app.complete_order', {
          p_order_id: orderId,
          p_payment_intent: paymentIntent,
          p_checkout_id: checkoutId,
        });
      }
    }
  } catch (e) {
    return new Response(`Handler error: ${String(e)}`, { status: 500 });
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});

