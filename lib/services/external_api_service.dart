import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour consommer des APIs externes
/// Récupère des citations de motivation sportive
class ExternalApiService {
  // API publique de citations (type.fit)
  static const String _quotesUrl = 'https://type.fit/api/quotes';
  
  // API alternative pour les citations sportives (plus ciblée)
  static const String _sportQuotesUrl = 
      'https://quotes.rest/qod?category=sports&language=fr';
  
  // API de secours avec des citations locales
  final List<String> _fallbackQuotes = const [
    "Le succès c'est tomber sept fois, se relever huit.",
    "La douleur est temporaire, l'abandon est pour toujours.",
    "Plus tu sues à l'entraînement, moins tu saignes en compétition.",
    "Le corps accomplit ce que l'esprit croit.",
    "Ne compte pas les jours, fais en sorte que chaque jour compte.",
    "Le champion a plus faim que les autres.",
    "Si ça ne te challenge pas, ça ne te change pas.",
    "La seule limite est celle que tu te fixes.",
    "Aujourd'hui, fais ce que les autres ne font pas pour avoir demain ce que les autres n'auront pas.",
    "Le succès est la somme de petits efforts répétés jour après jour.",
  ];

  /// Récupère une citation de motivation aléatoire
  Future<String?> fetchMotivationalQuote() async {
    try {
      final uri = Uri.parse(_quotesUrl);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          // Sélectionne une citation aléatoire
          final randomIndex = DateTime.now().millisecondsSinceEpoch % data.length;
          final quote = data[randomIndex] as Map<String, dynamic>;
          final text = quote['text'] as String?;
          final author = quote['author'] as String?;
          
          if (text != null) {
            return author != null && author != 'null' && author.isNotEmpty
                ? '$text — $author'
                : text;
          }
        }
      }
      
      // En cas d'échec, retourne une citation locale
      return _getRandomFallbackQuote();
    } catch (e) {
      print('Erreur API: $e');
      return _getRandomFallbackQuote();
    }
  }

  /// Récupère une citation spécifiquement sportive
  Future<String?> fetchSportQuote() async {
    try {
      final uri = Uri.parse(_sportQuotesUrl);
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contents = data['contents']?['quotes'] as List?;
        
        if (contents != null && contents.isNotEmpty) {
          final quote = contents[0];
          final text = quote['quote'] as String?;
          final author = quote['author'] as String?;
          
          if (text != null) {
            return author != null ? '$text — $author' : text;
          }
        }
      }
      
      return _getRandomFallbackQuote();
    } catch (e) {
      print('Erreur API sport: $e');
      return _getRandomFallbackQuote();
    }
  }

  /// Retourne une citation locale aléatoire
  String _getRandomFallbackQuote() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _fallbackQuotes.length;
    return _fallbackQuotes[randomIndex];
  }
}