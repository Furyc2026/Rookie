import 'dart:convert';
import 'package:http/http.dart' as http;
import 'potential_models.dart';

class PotentialApiService {
  static Future<PotentialApiResult> analyzeCompany({
    required String company,
    required String plz,
    required String branch,
  }) async {
    final uri = Uri.parse('http://localhost:8080/analyze-company');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company': company,
        'plz': plz,
        'branch': branch,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend-Fehler: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['success'] != true) {
      throw Exception(json['error'] ?? 'Unbekannter Backend-Fehler');
    }

    return PotentialApiResult.fromJson(json['data'] as Map<String, dynamic>);
  }
}