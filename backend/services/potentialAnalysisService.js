function normalizeText(value) {
  return (value || '').toString().trim();
}

function normalizeLower(value) {
  return normalizeText(value).toLowerCase();
}

function normalizeBranch(inputBranch, googleCategory) {
  const source = `${normalizeLower(inputBranch)} ${normalizeLower(googleCategory)}`;

  if (
    source.includes('retail') ||
    source.includes('einzelhandel') ||
    source.includes('supermarkt') ||
    source.includes('markt') ||
    source.includes('filiale')
  ) {
    return 'Filialisten / Einzelhandel';
  }

  if (
    source.includes('pflege') ||
    source.includes('krankenhaus') ||
    source.includes('gesund') ||
    source.includes('arzt') ||
    source.includes('praxis') ||
    source.includes('mvz') ||
    source.includes('medical') ||
    source.includes('health')
  ) {
    return 'Healthcare / Pflege';
  }

  if (
    source.includes('industrie') ||
    source.includes('produktion') ||
    source.includes('werk') ||
    source.includes('manufacturing')
  ) {
    return 'Industrie / Produktion';
  }

  if (
    source.includes('wohnen') ||
    source.includes('immobil') ||
    source.includes('housing') ||
    source.includes('wohnungs')
  ) {
    return 'Wohnungswirtschaft / Immobilien';
  }

  if (
    source.includes('fitness') ||
    source.includes('gym') ||
    source.includes('sportstudio')
  ) {
    return 'Fitness / Freizeit';
  }

  if (
    source.includes('hotel') ||
    source.includes('gastro') ||
    source.includes('restaurant') ||
    source.includes('cafe')
  ) {
    return 'Hotel / Gastro';
  }

  if (
    source.includes('logistik') ||
    source.includes('lager') ||
    source.includes('spedition') ||
    source.includes('logistics')
  ) {
    return 'Logistik / Lager';
  }

  if (
    source.includes('büro') ||
    source.includes('buero') ||
    source.includes('office') ||
    source.includes('dienstleistung') ||
    source.includes('service')
  ) {
    return 'Büro / Dienstleistung';
  }

  if (normalizeText(inputBranch).isNotEmpty) {
    return normalizeText(inputBranch);
  }

  return 'Unbekannt';
}

function branchBaseScore(branch) {
  switch (branch) {
    case 'Filialisten / Einzelhandel':
      return 18;
    case 'Healthcare / Pflege':
      return 16;
    case 'Industrie / Produktion':
      return 20;
    case 'Wohnungswirtschaft / Immobilien':
      return 14;
    case 'Fitness / Freizeit':
      return 12;
    case 'Hotel / Gastro':
      return 12;
    case 'Logistik / Lager':
      return 15;
    case 'Büro / Dienstleistung':
      return 8;
    default:
      return 5;
  }
}

function siteScore(value) {
  switch (value) {
    case '1':
      return 0;
    case '2-5':
      return 12;
    case '6-20':
      return 24;
    case '20+':
      return 34;
    default:
      return 4;
  }
}

function sizeScore(value) {
  switch (value) {
    case 'klein':
      return 4;
    case 'mittel':
      return 10;
    case 'gross':
      return 18;
    default:
      return 0;
  }
}

function decisionScore(value) {
  switch (value) {
    case 'zentral':
      return 12;
    case 'dezentral':
      return 6;
    default:
      return 0;
  }
}

function energyNeedScore(value) {
  switch (value) {
    case 'niedrig':
      return 2;
    case 'mittel':
      return 10;
    case 'hoch':
      return 18;
    default:
      return 0;
  }
}

function sustainabilityScore(value) {
  switch (value) {
    case 'mittel':
      return 6;
    case 'hoch':
      return 12;
    default:
      return 0;
  }
}

function locationTypeScore(value) {
  switch (value) {
    case 'einzelstandort':
      return 3;
    case 'filiale':
      return 14;
    case 'buero':
      return 6;
    case 'praxis':
      return 10;
    case 'pflege':
      return 16;
    case 'industrie':
      return 20;
    case 'lager':
      return 12;
    case 'gemischt':
      return 15;
    default:
      return 0;
  }
}

function guessConsumptionBand({ branch, energyNeed, siteCountCategory, companySize }) {
  if (energyNeed === 'hoch') {
    return 'eher hoch';
  }

  if (branch === 'Industrie / Produktion' || siteCountCategory === '20+' || companySize === 'gross') {
    return 'eher hoch';
  }

  if (
    branch === 'Filialisten / Einzelhandel' ||
    branch === 'Healthcare / Pflege' ||
    branch === 'Logistik / Lager' ||
    energyNeed === 'mittel'
  ) {
    return 'eher mittel';
  }

  return 'eher niedrig bis mittel';
}

function guessComplexity({ siteCountCategory, decisionStructure, locationType }) {
  let score = 0;

  if (siteCountCategory === '6-20') score += 2;
  if (siteCountCategory === '20+') score += 3;
  if (decisionStructure === 'dezentral') score += 1;
  if (locationType === 'gemischt') score += 2;
  if (locationType === 'industrie') score += 2;

  if (score >= 5) return 'hoch';
  if (score >= 2) return 'mittel';
  return 'niedrig';
}

function confidenceScore({
  company,
  plz,
  city,
  normalizedBranch,
  companyLookup,
  siteCountCategory,
  locationType,
  companySize,
  decisionStructure,
  energyNeed,
  sustainabilityInterest,
}) {
  let score = 0;

  if (company) score += 10;
  if (plz) score += 15;
  if (city) score += 8;
  if (normalizedBranch !== 'Unbekannt') score += 15;
  if (companyLookup?.found) score += 15;
  if (siteCountCategory !== 'unbekannt') score += 12;
  if (locationType !== 'unbekannt') score += 10;
  if (companySize !== 'unbekannt') score += 8;
  if (decisionStructure !== 'unbekannt') score += 8;
  if (energyNeed !== 'unbekannt') score += 12;
  if (sustainabilityInterest !== 'unbekannt') score += 7;

  return Math.max(0, Math.min(100, score));
}

function labelForPotential(score) {
  if (score >= 70) return 'Angriff';
  if (score >= 45) return 'Prüfen';
  return 'Beobachten';
}

function labelForConfidence(score) {
  if (score >= 75) return 'hoch';
  if (score >= 45) return 'mittel';
  return 'niedrig';
}

function buildReasons({
  normalizedBranch,
  siteCountCategory,
  companySize,
  decisionStructure,
  energyNeed,
  sustainabilityInterest,
  companyLookup,
}) {
  const reasons = [];

  if (normalizedBranch !== 'Unbekannt') {
    reasons.push(`Branche erkannt: ${normalizedBranch}`);
  }

  if (siteCountCategory === '6-20' || siteCountCategory === '20+') {
    reasons.push('Mehrere Standorte sprechen für Bündelungs- und Strukturpotenzial.');
  }

  if (companySize === 'gross') {
    reasons.push('Größere Unternehmensstruktur deutet auf relevantere Energiemengen hin.');
  }

  if (decisionStructure === 'zentral') {
    reasons.push('Zentrale Entscheidungsstruktur ist vertrieblich günstiger.');
  }

  if (energyNeed === 'hoch') {
    reasons.push('Hoher geschätzter Energiebedarf erhöht die Relevanz eines Gesprächs.');
  }

  if (sustainabilityInterest === 'hoch') {
    reasons.push('Hoher ESG-/Nachhaltigkeitsfit passt gut zur Vattenfall-Story.');
  }

  if (companyLookup?.found) {
    reasons.push('Unternehmen wurde in der Suche plausibel gefunden und verifiziert.');
  }

  return reasons;
}

function buildRisks({
  normalizedBranch,
  siteCountCategory,
  companySize,
  decisionStructure,
  energyNeed,
  companyLookup,
}) {
  const risks = [];

  if (!companyLookup?.found) {
    risks.push('Unternehmen konnte nicht eindeutig verifiziert werden.');
  }

  if (normalizedBranch === 'Unbekannt') {
    risks.push('Branche unklar – dadurch wird die Schätzung unsicherer.');
  }

  if (siteCountCategory === 'unbekannt') {
    risks.push('Standortanzahl unbekannt – Bündelungspotenzial nicht sicher einschätzbar.');
  }

  if (companySize === 'unbekannt') {
    risks.push('Unternehmensgröße unbekannt – Mengenrelevanz bleibt offen.');
  }

  if (decisionStructure === 'unbekannt') {
    risks.push('Entscheidungsstruktur unklar – Zugangsweg zum Kunden offen.');
  }

  if (energyNeed === 'unbekannt') {
    risks.push('Energiebedarf ist nur grob schätzbar.');
  }

  return risks;
}

function buildSalesApproach(branch, score) {
  if (score >= 70) {
    if (branch === 'Filialisten / Einzelhandel') {
      return 'Einstieg über Bündelung, Transparenz und zentrale Steuerung mehrerer Standorte.';
    }
    if (branch === 'Healthcare / Pflege') {
      return 'Einstieg über Stabilität, Planbarkeit und geringen internen Aufwand.';
    }
    if (branch === 'Industrie / Produktion') {
      return 'Einstieg über Versorgungssicherheit, Beschaffungsstrategie und Marktlogik.';
    }
    return 'Einstieg über Struktur, Transparenz und strategische Beschaffung statt reiner Preisansprache.';
  }

  if (score >= 45) {
    return 'Erst qualifizieren: Struktur, Bedarf und Entscheidungsweg klären, bevor zu tief eingestiegen wird.';
  }

  return 'Kurz prüfen, aber Aufwand niedrig halten. Erst harte Relevanzsignale suchen.';
}

function buildNextStep(score, confidence, companyLookupFound) {
  if (score >= 70 && confidence >= 60) {
    return 'Aktiv anrufen oder Termin anbahnen und auf Entscheiderebene gehen.';
  }

  if (score >= 45) {
    return 'Erstgespräch mit Fokus auf Qualifizierung: Standorte, Verträge, Laufzeiten, Zuständigkeiten.';
  }

  if (!companyLookupFound) {
    return 'Unternehmen erst sauber verifizieren, bevor weitere Zeit investiert wird.';
  }

  return 'Lead beobachten oder nur mit sehr geringem Zeitaufwand weiterprüfen.';
}

function buildGreenAngle(branch, sustainabilityInterest) {
  if (sustainabilityInterest === 'hoch') {
    return 'Nachhaltigkeit aktiv ansprechen: fossilfreie Zukunft, CO₂-Reduktion und strategische Versorgung.';
  }

  if (branch === 'Wohnungswirtschaft / Immobilien') {
    return 'Green Angle: zukunftsfähige Versorgung, Transparenz und Nachhaltigkeit für Bestandshalter.';
  }

  if (branch === 'Industrie / Produktion') {
    return 'Green Angle: Transformation, Versorgungssicherheit und belastbare Dekarbonisierungsperspektive.';
  }

  if (branch === 'Filialisten / Einzelhandel') {
    return 'Green Angle: skalierbare, transparentere und nachhaltig ausrichtbare Versorgung über mehrere Standorte.';
  }

  return 'Green Angle: Nachhaltigkeit nur ergänzend spielen, nicht als einziges Argument.';
}

function buildPotentialAnalysis({
  input,
  companyLookup,
  grundversorgerHint,
}) {
  const company = normalizeText(input.company);
  const plz = normalizeText(input.plz);
  const city = normalizeText(input.city);
  const branch = normalizeText(input.branch);
  const siteCountCategory = normalizeLower(input.siteCountCategory || 'unbekannt');
  const locationType = normalizeLower(input.locationType || 'unbekannt');
  const companySize = normalizeLower(input.companySize || 'unbekannt');
  const decisionStructure = normalizeLower(input.decisionStructure || 'unbekannt');
  const energyNeed = normalizeLower(input.energyNeed || 'unbekannt');
  const sustainabilityInterest = normalizeLower(input.sustainabilityInterest || 'unbekannt');

  const normalizedBranch = normalizeBranch(branch, companyLookup?.category || '');

  let potentialScore = 0;
  potentialScore += branchBaseScore(normalizedBranch);
  potentialScore += siteScore(siteCountCategory);
  potentialScore += sizeScore(companySize);
  potentialScore += decisionScore(decisionStructure);
  potentialScore += energyNeedScore(energyNeed);
  potentialScore += sustainabilityScore(sustainabilityInterest);
  potentialScore += locationTypeScore(locationType);

  if (companyLookup?.found) {
    potentialScore += 8;
  }

  if (companyLookup?.website) {
    potentialScore += 4;
  }

  if (
    normalizedBranch === 'Filialisten / Einzelhandel' &&
    (siteCountCategory === '6-20' || siteCountCategory === '20+')
  ) {
    potentialScore += 8;
  }

  potentialScore = Math.max(0, Math.min(100, potentialScore));

  const confidence = confidenceScore({
    company,
    plz,
    city,
    normalizedBranch,
    companyLookup,
    siteCountCategory,
    locationType,
    companySize,
    decisionStructure,
    energyNeed,
    sustainabilityInterest,
  });

  const estimatedConsumptionBand = guessConsumptionBand({
    branch: normalizedBranch,
    energyNeed,
    siteCountCategory,
    companySize,
  });

  const estimatedComplexity = guessComplexity({
    siteCountCategory,
    decisionStructure,
    locationType,
  });

  return {
    companyInput: company,
    normalizedBranch,
    heuristicNotice:
      'Heuristische Einschätzung auf Basis der Eingaben, Branchenlogik und gefundener Unternehmenshinweise. Keine belastbare Verbrauchs-, Standort- oder Vertragsanalyse.',
    potentialScore,
    scoreLabel: labelForPotential(potentialScore),
    confidenceScore: confidence,
    confidenceLabel: labelForConfidence(confidence),
    estimatedConsumptionBand,
    estimatedComplexity,
    reasons: buildReasons({
      normalizedBranch,
      siteCountCategory,
      companySize,
      decisionStructure,
      energyNeed,
      sustainabilityInterest,
      companyLookup,
    }),
    risks: buildRisks({
      normalizedBranch,
      siteCountCategory,
      companySize,
      decisionStructure,
      energyNeed,
      companyLookup,
    }),
    nextStep: buildNextStep(potentialScore, confidence, companyLookup?.found),
    salesApproach: buildSalesApproach(normalizedBranch, potentialScore),
    greenAngle: buildGreenAngle(normalizedBranch, sustainabilityInterest),
    grundversorgerHint,
  };
}

module.exports = {
  buildPotentialAnalysis,
};