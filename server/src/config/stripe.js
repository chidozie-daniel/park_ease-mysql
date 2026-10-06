const Stripe = require('stripe');

const apiKey = process.env.STRIPE_SECRET_KEY;
const stripe = apiKey ? new Stripe(apiKey) : null;

module.exports = stripe;