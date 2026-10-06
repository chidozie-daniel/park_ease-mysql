const { HttpError } = require('../errors');

function notFound(req, res, next) {
  next(new HttpError(404, `Route not found: ${req.method} ${req.originalUrl}`));
}

function errorHandler(err, req, res, next) {
  if (err instanceof HttpError) {
    return res.status(err.status).json({ message: err.message });
  }

  console.error('[error]', err);

  const internal = new HttpError(500, 'Internal server error');
  return res.status(internal.status).json({ message: internal.message });
}

module.exports = { notFound, errorHandler };