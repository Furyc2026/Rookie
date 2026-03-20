const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { searchCompanyAndScore } = require('./services/googlePlacesService');
const { generateMarketData } = require('./services/marketService');
const { buildGrundversorgerHint } = require('./services/grundversorgerService');
const { buildPotentialAnalysis } = require('./services/potentialAnalysisService');

dotenv.config();

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

app.get('/market', async (req, res) => {
  try {
    const data = await generateMarketData();
    res.json({
      success: true,
      data,
    });
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
    const {
      company,
      plz,
      city,
      branch,
      siteCountCategory,
      locationType,
      companySize,
      decisionStructure,
      energyNeed,
      sustainabilityInterest,
    } = req.body || {};

    if (!company || !plz) {
      return res.status(400).json({
        success: false,
        error: 'Bitte Firmenname und PLZ angeben.',
      });
    }

    let companyLookup = {
      found: false,
      companyInput: company,
      matchedCompany: '',
      address: '',
      category: '',
      website: '',
      phone: '',
      rating: null,
      userRatingsTotal: null,
    };

    try {
      const lookupResult = await searchCompanyAndScore({
        company,
        plz,
        branch: branch || '',
      });

      companyLookup = {
        found: lookupResult?.found === true,
        companyInput: lookupResult?.companyInput || company,
        matchedCompany: lookupResult?.matchedCompany || '',
        address: lookupResult?.address || '',
        category: lookupResult?.category || '',
        website: lookupResult?.website || '',
        phone: lookupResult?.phone || '',
        rating: lookupResult?.rating ?? null,
        userRatingsTotal: lookupResult?.userRatingsTotal ?? null,
      };
    } catch (lookupError) {
      console.error('Lookup warning:', lookupError.message);
    }

    const grundversorgerHint = buildGrundversorgerHint({
      plz,
      city,
      address: companyLookup.address,
    });

    const heuristic = buildPotentialAnalysis({
      input: {
        company,
        plz,
        city,
        branch,
        siteCountCategory,
        locationType,
        companySize,
        decisionStructure,
        energyNeed,
        sustainabilityInterest,
      },
      companyLookup,
      grundversorgerHint,
    });

    return res.json({
      success: true,
      data: {
        input: {
          company,
          plz,
          city: city || '',
          branch: branch || '',
          siteCountCategory: siteCountCategory || 'unbekannt',
          locationType: locationType || 'unbekannt',
          companySize: companySize || 'unbekannt',
          decisionStructure: decisionStructure || 'unbekannt',
          energyNeed: energyNeed || 'unbekannt',
          sustainabilityInterest: sustainabilityInterest || 'unbekannt',
        },
        companyLookup,
        heuristic,
      },
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

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend läuft auf Port ${PORT}`);
});