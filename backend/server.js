const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 10000;

app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'energy-sales-rookie-backend',
  });
});

app.get('/market', (req, res) => {
  res.json({
    success: true,
    data: {
      timestamp: new Date().toISOString(),
      source: 'Mock Market Data',
      note: 'Demo Daten vom Backend',
      power: {
        current: 95.58,
        previous: 111.11,
        delta: -15.53,
        direction: 'down',
        salesHint: 'Stromtrend fällt → guter Einstieg für Neuansätze',
        label: 'Stromtrend',
        periodLabel: 'Ø letzte 7 Tage',
        comparisonLabel: 'Ø 7 Tage davor',
        isAvailable: true,
      },
    },
  });
});

app.post('/analyze-company', (req, res) => {
  const { company, plz, branch } = req.body;

  res.json({
    success: true,
    data: {
      company,
      plz,
      branch,
      score: 78,
      recommendation: 'Guter Zielkunde für Bündelung und Strukturierung',
    },
  });
});

app.listen(PORT, () => {
  console.log(`Backend läuft auf Port ${PORT}`);
});