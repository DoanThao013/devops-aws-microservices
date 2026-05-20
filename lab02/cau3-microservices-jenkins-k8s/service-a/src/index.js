const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVICE_B_URL = process.env.SERVICE_B_URL || 'http://service-b:5000';

app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'service-a' }));

app.get('/', (_req, res) => res.json({ message: 'Hello from Service A (Node.js)' }));

app.get('/aggregate', async (_req, res) => {
  try {
    const r = await axios.get(`${SERVICE_B_URL}/data`, { timeout: 3000 });
    res.json({ from: 'service-a', upstream: r.data });
  } catch (err) {
    res.status(502).json({ error: 'service-b unavailable', detail: err.message });
  }
});

if (require.main === module) {
  app.listen(PORT, () => console.log(`service-a listening on ${PORT}`));
}

module.exports = app;
