const { scoreCompany } = require('./scoringService');

function maskKey(key) {
  if (!key || key.length < 10) return 'ungueltig/leer';
  return `${key.slice(0, 6)}...${key.slice(-4)}`;
}

async function searchCompanyAndScore({ company, plz, branch }) {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;

  console.log('Google Key im Service:', maskKey(apiKey));

  const query = `${company} ${plz} Deutschland`;

  const searchResponse = await fetch(
    'https://places.googleapis.com/v1/places:searchText',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
          'places.id,places.displayName,places.formattedAddress,places.types,places.websiteUri,places.businessStatus',
      },
      body: JSON.stringify({
        textQuery: query,
        languageCode: 'de',
      }),
    }
  );

  const rawText = await searchResponse.text();

  if (!searchResponse.ok) {
    throw new Error(`Text Search Fehler (${searchResponse.status}): ${rawText}`);
  }

  const searchData = JSON.parse(rawText);
  const places = searchData.places || [];

  if (!places.length) {
    return {
      found: false,
      message: 'Kein passendes Unternehmen gefunden.',
    };
  }

  const best = places[0];

  const detailsResponse = await fetch(
    `https://places.googleapis.com/v1/places/${best.id}`,
    {
      headers: {
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
          'id,displayName,formattedAddress,websiteUri,types,nationalPhoneNumber,businessStatus',
      },
    }
  );

  const detailsRaw = await detailsResponse.text();

  if (!detailsResponse.ok) {
    throw new Error(`Place Details Fehler (${detailsResponse.status}): ${detailsRaw}`);
  }

  const details = JSON.parse(detailsRaw);
  const scoring = scoreCompany({ place: best, details, branch });

  return {
    found: true,
    companyInput: company,
    matchedCompany: details.displayName?.text || best.displayName?.text || company,
    address: details.formattedAddress || best.formattedAddress || '',
    website: details.websiteUri || best.websiteUri || '',
    types: details.types || best.types || [],
    businessStatus: details.businessStatus || '',
    confidenceScore: buildConfidence(best, details, plz),
    ...scoring,
  };
}

function buildConfidence(place, details, plz) {
  let score = 55;

  const address = (details?.formattedAddress || place?.formattedAddress || '').toLowerCase();
  if (address.includes(plz)) score += 20;
  if (details?.websiteUri) score += 10;
  if ((details?.types || place?.types || []).length) score += 10;
  if (details?.businessStatus) score += 5;

  if (score > 100) score = 100;
  return score;
}

module.exports = { searchCompanyAndScore };