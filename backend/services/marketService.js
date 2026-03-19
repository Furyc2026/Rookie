const MS_PER_HOUR = 60 * 60 * 1000;
const MS_PER_DAY = 24 * MS_PER_HOUR;

const ENERGY_CHARTS_BZN = 'DE-LU';

async function generateMarketData() {
  const power = await fetchPowerTrend7d();

  return {
    timestamp: new Date().toISOString(),
    source: 'Energy-Charts',
    note:
      'Wochen-Trends zur Markteinordnung, keine tagesaktuellen Börsenpreise. Strom basiert auf Energy-Charts (7-Tage-Durchschnitt).',
    power,
  };
}

async function fetchPowerTrend7d() {
  const now = new Date();
  const end = floorToHour(new Date(now.getTime() - MS_PER_HOUR));
  const start = new Date(end.getTime() - (14 * MS_PER_DAY) + MS_PER_HOUR);

  const url =
    `https://api.energy-charts.info/price?bzn=${ENERGY_CHARTS_BZN}` +
    `&start=${toUnixSeconds(start)}` +
    `&end=${toUnixSeconds(end)}`;

  const response = await fetch(url, {
    headers: { accept: 'application/json' },
  });

  if (!response.ok) {
    throw new Error(`Energy-Charts Fehler: HTTP ${response.status}`);
  }

  const payload = await response.json();

  if (!payload || !Array.isArray(payload.price) || payload.price.length < 24 * 8) {
    throw new Error('Energy-Charts lieferte keine verwertbaren Strompreisdaten.');
  }

  const prices = payload.price.filter(
    (value) => typeof value === 'number' && Number.isFinite(value)
  );

  if (prices.length < 24 * 8) {
    throw new Error('Zu wenige Strompreisdaten für 7-Tage-Trend.');
  }

  const currentWindow = prices.slice(-24 * 7);
  const previousWindow = prices.slice(-24 * 14, -24 * 7);

  const currentAvg = average(currentWindow);
  const previousAvg = average(previousWindow);
  const delta = currentAvg - previousAvg;

  return buildMetric({
    label: 'Stromtrend 7 Tage (DE-LU Day-Ahead Ø)',
    current: currentAvg,
    previous: previousAvg,
    delta,
    type: 'strom',
    periodLabel: 'Ø letzte 7 Tage',
    comparisonLabel: 'Ø 7 Tage davor',
  });
}

function buildMetric({
  label,
  current,
  previous,
  delta,
  type,
  periodLabel,
  comparisonLabel,
}) {
  const direction =
    delta > 0.5 ? 'up' :
    delta < -0.5 ? 'down' :
    'stable';

  return {
    label,
    current: round2(current),
    previous: round2(previous),
    delta: round2(delta),
    direction,
    salesHint: getSalesHint(direction, type),
    periodLabel,
    comparisonLabel,
    isAvailable: true,
  };
}

function getSalesHint(direction, type) {
  if (type === 'strom') {
    if (direction === 'up') {
      return 'Stromtrend steigt → Preisabsicherung und Timing aktiv ansprechen.';
    }
    if (direction === 'down') {
      return 'Stromtrend fällt → guter Gesprächseinstieg für Neuansätze und Re-Entry.';
    }
    return 'Stromtrend stabil → Fokus auf Bedarf, Laufzeit und Vertragsstruktur.';
  }

  return 'Markt stabil → Fokus auf Bedarf, Laufzeit und Vertragsstruktur.';
}

function average(values) {
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function round2(value) {
  return Number(value.toFixed(2));
}

function floorToHour(date) {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    date.getHours(),
    0,
    0,
    0
  );
}

function toUnixSeconds(date) {
  return Math.floor(date.getTime() / 1000);
}

module.exports = { generateMarketData };