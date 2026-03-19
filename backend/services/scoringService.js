function scoreCompany({ place, details, branch }) {
  let stromBase = 30000;
  let gasBase = 8000;
  const reasons = [];
  const hints = [];

  const name = (place?.displayName?.text || '').toLowerCase();
  const website = (details?.websiteUri || '').toLowerCase();
  const types = details?.types || place?.types || [];
  const normalizedBranch = (branch || '').toLowerCase();

  if (name.includes('hotel') || types.includes('lodging')) {
    stromBase += 140000;
    gasBase += 160000;
    reasons.push('Hotellerie deutet auf erhöhten Strom- und Wärmebedarf hin.');
  }

  if (
    name.includes('mvz') ||
    name.includes('klinik') ||
    name.includes('pflege') ||
    name.includes('arzt') ||
    types.includes('hospital') ||
    types.includes('doctor') ||
    types.includes('dentist')
  ) {
    stromBase += 120000;
    gasBase += 50000;
    reasons.push('Gesundheitsnahe Nutzung spricht für konstanten Energiebedarf.');
  }

  if (
    name.includes('gruppe') ||
    name.includes('holding') ||
    name.includes('beteiligung') ||
    website.includes('standorte') ||
    website.includes('locations')
  ) {
    stromBase += 100000;
    gasBase += 35000;
    reasons.push('Es gibt Hinweise auf eine mehrgliedrige Unternehmensstruktur.');
    hints.push('Prüfen, ob mehrere Standorte gebündelt werden können.');
  }

  if (
    types.includes('store') ||
    types.includes('supermarket') ||
    types.includes('pharmacy')
  ) {
    stromBase += 80000;
    gasBase += 20000;
    reasons.push('Die Kategorie deutet auf filialartige oder frequenzbasierte Nutzung hin.');
  }

  if (
    normalizedBranch === 'wohnungswirtschaft' ||
    name.includes('wohnen') ||
    name.includes('immobilien') ||
    name.includes('hausverwaltung')
  ) {
    stromBase += 40000;
    gasBase += 140000;
    reasons.push('Wohnungswirtschaft spricht für relevantes Gas- und Bündelpotenzial.');
  }

  if (normalizedBranch === 'filialisten') {
    stromBase += 100000;
    gasBase += 30000;
    reasons.push('Filialstruktur erzeugt meist Bündelpotenzial.');
  }

  if (normalizedBranch === 'industrie') {
    stromBase += 240000;
    gasBase += 180000;
    reasons.push('Industrie weist meist hohen Energiebedarf auf.');
  }

  if (normalizedBranch === 'gesundheitswesen') {
    stromBase += 130000;
    gasBase += 50000;
    reasons.push('Gesundheitswesen benötigt stabile Versorgung.');
  }

  let level = 'LOW';
  const total = stromBase + gasBase;
  if (total >= 450000) {
    level = 'HIGH';
  } else if (total >= 180000) {
    level = 'MID';
  }

  return {
    level,
    stromRange: `${formatNumber(stromBase)} – ${formatNumber(Math.round(stromBase * 1.8))} kWh`,
    gasRange: `${formatNumber(gasBase)} – ${formatNumber(Math.round(gasBase * 1.8))} kWh`,
    reasoning: reasons.length
      ? reasons.join(' ')
      : 'Die Bewertung basiert auf Unternehmensdaten aus dem Treffer und Standardlogik.',
    hints,
  };
}

function formatNumber(num) {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

module.exports = { scoreCompany };