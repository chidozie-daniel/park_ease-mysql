const express = require('express');
const cors = require('cors');

const { errorHandler, notFound } = require('./middleware/errorHandler');

const app = express();

app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'park-ease-api' });
});

app.use('/api/v1/auth', require('./routes/auth'));
app.use('/api/v1/users', require('./routes/users'));
app.use('/api/v1/parking', require('./routes/parking'));
app.use('/api/v1/bookings', require('./routes/bookings'));
app.use('/api/v1/vehicles', require('./routes/vehicles'));
app.use('/api/v1/payments', require('./routes/payments'));
app.use('/api/v1/notifications', require('./routes/notifications'));
app.use('/api/v1/admin', require('./routes/admin'));

app.use(notFound);
app.use(errorHandler);

module.exports = app;