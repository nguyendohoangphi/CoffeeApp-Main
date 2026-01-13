const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const Stripe = require("stripe");

setGlobalOptions({ maxInstances: 10 });


const stripe = new Stripe(
  process.env.STRIPE_SECRET_KEY,
  { apiVersion: "2023-10-16" }
);

exports.createPaymentIntent = onRequest(
  { cors: true, secrets: ["STRIPE_SECRET_KEY"] },
  async (req, res) => {
    try {
      const { amount, currency } = req.body;

      if (!amount || !currency) {
        res.status(400).json({ error: "Missing amount or currency" });
        return;
      }

      const paymentIntent = await stripe.paymentIntents.create({
        amount,
        currency,
        automatic_payment_methods: { enabled: true },
      });

      res.json({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
      logger.error(error);
      res.status(500).json({ error: error.message });
    }
  }
);
