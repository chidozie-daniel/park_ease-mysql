const { HttpError } = require('../errors');

function requireAdmin(req, res, next) {
  if (!req.user || req.user.role !== 'admin') {
    next(new HttpError(403, 'Admin access required'));
    return;
  }
  next();
}

module.exports = { requireAdmin };