import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MarketApiService {
  Future<Map<String, dynamic>> fetchMarketData() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/market');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Laden der Marktdaten');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception('Backend hat Fehler geliefert');
    }

    return data['data'];
  }
}