import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../services/external_api_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with SingleTickerProviderStateMixin {
  final ExternalApiService _apiService = ExternalApiService();

  String? _currentQuote;
  bool _isLoading = false;
  bool _isFavorite = false;
  final List<String> _favoriteQuotes = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadTodayQuote();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final quote = await _apiService.fetchRandomQuote();

      if (mounted) {
        setState(() {
          _currentQuote = quote;
          _isLoading = false;
          _isFavorite = _favoriteQuotes.contains(quote);
        });

        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentQuote = 'Impossible de charger la citation.';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite() {
    if (_currentQuote == null) return;

    setState(() {
      if (_isFavorite) {
        _favoriteQuotes.remove(_currentQuote);
      } else {
        _favoriteQuotes.add(_currentQuote!);
      }
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '✓ Citation ajoutée aux favoris'
              : '✗ Citation retirée des favoris',
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareQuote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de partage à venir'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Motivation du jour',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _shareQuote,
            icon: const Icon(Icons.share, color: Color(0xFF1E293B)),
          ),
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _buildQuoteCard(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Recharger la citation du jour'),
                  onPressed: _isLoading ? null : _loadTodayQuote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Adapte l'affichage de la citation pour coller au format renvoyé par ExternalApiService (texte, auteur, date, url)
  Widget _buildQuoteCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _currentQuote != null && _currentQuote!.isNotEmpty
                  ? _buildFormattedQuoteText(_currentQuote!)
                  : const Text(
                      'Aucune citation à afficher.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Sépare la citation en texte, auteur, date, url et affiche joliment
  /// Format attendu: “Lorem ipsum ...”\n— John Doe\n2024-06-07\nhttp...
  Widget _buildFormattedQuoteText(String quote) {
    final parts = quote.split('\n');
    // On gère le cas où la structure ne correspond pas (fallback)
    String body = parts.isNotEmpty ? parts[0] : '';
    String author = parts.length > 1 ? parts[1] : '';
    String date = parts.length > 2 ? parts[2] : '';
    String url = parts.length > 3 ? parts[3] : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        if (author.isNotEmpty)
          Text(
            author,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
        if (date.isNotEmpty)
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        if (url.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              onTap: () {
                // Optionnel (ouvrir le lien)
              },
              child: Text(
                url,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
