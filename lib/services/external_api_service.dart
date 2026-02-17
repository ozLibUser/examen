import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour récupérer des citations depuis l'API QuoteDay
class ExternalApiService {
  static const String _quoteUrl = 'https://quoteday.dev/api/quote/today';
  static const String _apiKey = 'qd_live_eKZQyZIYp1B2KsugyVeetjdb8BNOIliX';

  /// Récupère la citation du jour depuis QuoteDay
  Future<String?> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(_quoteUrl),
        headers: {'X-API-KEY': _apiKey},
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => http.Response('Timeout', 408),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = (data['quote'] ?? '').toString();
        final String author = (data['author'] ?? '').toString().isEmpty
            ? 'Anonyme'
            : (data['author'] ?? '').toString();
        final String date = (data['date'] ?? '').toString();
        final String category = (data['category'] ?? '').toString();

        // Optionally, generate a URL (not returned by the API)
        final String url = '';

        // Format: “quote”\n— author\n2026-02-17\ncategory (or url, left blank)
        return '“$text”\n— $author\n$date\n$url';
      } else {
        print('Erreur HTTP: Code ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur récupération de la citation: $e');
    }
    return null;
  }

  /// Récupère une citation filtrée (pas de endpoint pour filtrer sur QuoteDay, fallback sur fetchRandomQuote)
  Future<String?> fetchFilteredQuote({String keyword = ''}) async {
    // L'API QuoteDay ne supporte pas de keyword/filter.
    return fetchRandomQuote();
  }
}
