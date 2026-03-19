const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { searchCompanyAndScore } = require('./services/googlePlacesService');
const { generateMarketData } = require('./services/marketService');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'energy-sales-rookie-backend' });
});

app.get('/market', async (req, res) => {
  try {
    const data = await generateMarketData();
    res.json({ success: true, data });
  } catch (error) {
    console.error('Market error:', error);
    res.status(500).json({
      success: false,
      error: 'Marktentwicklung konnte nicht geladen werden.',
      details: error.message,
    });
  }
});

app.post('/analyze-company', async (req, res) => {
  try {
    const { company, plz, branch } = req.body || {};

    if (!company || !plz) {
      return res.status(400).json({
        success: false,
        error: 'Bitte Firmenname und PLZ angeben.',
      });
    }

    const result = await searchCompanyAndScore({
      company,
      plz,
      branch: branch || '',
    });

    return res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Analyze error:', error);
    return res.status(500).json({
      success: false,
      error: 'Interner Fehler bei der Unternehmensanalyse.',
      details: error.message,
    });
  }
});

const port = process.env.PORT || 8080;

app.listen(port, '0.0.0.0', () => {
  console.log(`Backend läuft auf Port ${port}`);
});