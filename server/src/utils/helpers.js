const crypto = require('crypto');

function uuid() {
  return crypto.randomUUID();
}

function generateOtp() {
  return String(crypto.randomInt(100000, 999999));
}

const wrap =
  (fn) =>
  (req, res, next) =>
    Promise.resolve(fn(req, res, next)).catch(next);

module.exports = { uuid, generateOtp, wrap };