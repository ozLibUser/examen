import 'dart:convert';

import 'package:http/http.dart' as http;

/// Exemple simple de consommation d’API REST externe
/// (exigence du canevas de l’examen).
///
/// Ici on récupère une citation de motivation sportive.
class ExternalApiService {
  Future<String?> fetchMotivationalQuote() async {
    // API publique de citation — peut être changée au besoin.
    final uri = Uri.parse('https://type.fit/api/quotes');

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    if (data.isEmpty) return null;

    final randomQuote = (data.first as Map<String, dynamic>);
    return randomQuote['text'] as String?;
  }
}

