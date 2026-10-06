const jwt = require('jsonwebtoken');

const db = require('../db');
const { HttpError } = require('../errors');

async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) {
      throw new HttpError(401, 'Authentication required');
    }

    let payload;
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET);
    } catch (e) {
      throw new HttpError(401, 'Invalid or expired session');
    }

    const [rows] = await db.query(
      `SELECT id, name, email, phone, role, is_active, created_at, updated_at
       FROM users WHERE id = ?`,
      [payload.sub]
    );

    if (!rows.length || !rows[0].is_active) {
      throw new HttpError(401, 'Invalid or expired session');
    }

    req.user = rows[0];
    req.token = token;
    next();
  } catch (err) {
    next(err);
  }
}

module.exports = { requireAuth };