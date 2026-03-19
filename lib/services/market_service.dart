import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketMetric {
  final double current;
  final double previous;
  final double delta;
  final String direction;
  final String salesHint;
  final String label;
  final String periodLabel;
  final String comparisonLabel;
  final bool isAvailable;

  MarketMetric({
    required this.current,
    required this.previous,
    required this.delta,
    required this.direction,
    required this.salesHint,
    required this.label,
    required this.periodLabel,
    required this.comparisonLabel,
    required this.isAvailable,
  });

  bool get isUp => direction == 'up';
  bool get isDown => direction == 'down';
  bool get isStable => direction == 'stable';

  String get arrow {
    if (isUp) return '↑';
    if (isDown) return '↓';
    return '→';
  }

  String get directionText {
    if (isUp) return 'steigend';
    if (isDown) return 'fallend';
    return 'stabil';
  }
}

class MarketData {
  final MarketMetric power;
  final String source;
  final String note;
  final String timestamp;

  MarketData({
    required this.power,
    required this.source,
    required this.note,
    required this.timestamp,
  });
}

class MarketService {
  static Future<MarketData> fetchMarketData() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/market'),
    );

    if (response.statusCode != 200) {
      throw Exception('Marktentwicklung konnte nicht geladen werden.');
    }

    final decoded = json.decode(response.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['error'] ?? 'Unbekannter Market-Fehler');
    }

    final data = decoded['data'];

    MarketMetric parseMetric(Map<String, dynamic> metric, String fallbackLabel) {
      return MarketMetric(
        current: (metric['current'] as num?)?.toDouble() ?? 0,
        previous: (metric['previous'] as num?)?.toDouble() ?? 0,
        delta: (metric['delta'] as num?)?.toDouble() ?? 0,
        direction: metric['direction'] ?? 'stable',
        salesHint: metric['salesHint'] ?? '',
        label: metric['label'] ?? fallbackLabel,
        periodLabel: metric['periodLabel'] ?? 'Aktuelle Periode',
        comparisonLabel: metric['comparisonLabel'] ?? 'Vergleichsperiode',
        isAvailable: metric['isAvailable'] ?? true,
      );
    }

    return MarketData(
      power: parseMetric(
        Map<String, dynamic>.from(data['power']),
        'Stromtrend',
      ),
      source: data['source'] ?? 'Unbekannt',
      note: data['note'] ?? '',
      timestamp: data['timestamp'] ?? '',
    );
  }
}