const CITY_HINTS = [
  {
    match: ['hamburg'],
    name: 'Vattenfall Europe Sales GmbH',
    confidence: 'mittel',
    basis: 'Hinweis auf Hamburg',
    note: 'Orientierungshinweis auf Basis von Ort/Adresse. Bitte im Einzelfall prüfen.',
  },
  {
    match: ['koblenz'],
    name: 'evm Energieversorgung Mittelrhein AG',
    confidence: 'mittel',
    basis: 'Hinweis auf Koblenz / Netzgebiet Mittelrhein',
    note: 'Orientierungshinweis auf Basis von Ort/Adresse. Bitte im Einzelfall prüfen.',
  },
  {
    match: ['köln', 'koeln'],
    name: 'RheinEnergie AG',
    confidence: 'mittel',
    basis: 'Hinweis auf Köln',
    note: 'Orientierungshinweis auf Basis von Ort/Adresse. Bitte im Einzelfall prüfen.',
  },
];

function normalizeText(value) {
  return (value || '').toString().trim().toLowerCase();
}

function buildGrundversorgerHint({ plz, city, address }) {
  const normalizedCity = normalizeText(city);
  const normalizedAddress = normalizeText(address);
  const normalizedPlz = (plz || '').toString().trim();

  const combined = `${normalizedCity} ${normalizedAddress} ${normalizedPlz}`;

  for (const item of CITY_HINTS) {
    const isMatch = item.match.some((keyword) => combined.includes(keyword));
    if (isMatch) {
      return {
        available: true,
        name: item.name,
        confidence: item.confidence,
        basis: item.basis,
        note: item.note,
      };
    }
  }

  return {
    available: false,
    name: 'Noch nicht hinterlegt',
    confidence: 'niedrig',
    basis: 'Für diese PLZ/Region liegt aktuell nur ein Heuristik-Hinweis vor.',
    note: 'Die Angabe ist nicht sicher ableitbar. Bitte Netzgebiet bzw. Lieferstelle im Einzelfall prüfen.',
  };
}

module.exports = {
  buildGrundversorgerHint,
};