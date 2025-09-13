// deno-lint-ignore-file no-explicit-any
import Stripe from "https://esm.sh/stripe@12.16.0?target=deno";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }
  try {
    const body = await req.json();
    const {
      order_id,
      amount_cents,
      currency = 'sek',
      success_url,
      cancel_url,
      customer_email,
    } = body;

    if (!order_id || !amount_cents || !success_url || !cancel_url) {
      return new Response(JSON.stringify({ error: 'Missing parameters' }), { status: 400 });
    }

    const secret = Deno.env.get('STRIPE_SECRET_KEY');
    if (!secret) return new Response('Stripe not configured', { status: 500 });
    const stripe = new Stripe(secret, { apiVersion: '2024-06-20' });

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      success_url,
      cancel_url,
      currency,
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency,
            product_data: { name: 'Course purchase' },
            unit_amount: amount_cents,
          },
        },
      ],
      payment_intent_data: {
        metadata: { order_id },
      },
      metadata: { order_id },
      customer_email,
    });

    return new Response(JSON.stringify({ id: session.id, url: session.url }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});

