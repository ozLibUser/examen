import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
    } catch (e) {
      _error = 'Erreur de connexion';
      if (kDebugMode) {
        // ignore: avoid_print
        print(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
    } catch (e) {
      _error = 'Erreur lors de l\'inscription';
      if (kDebugMode) {
        // ignore: avoid_print
        print(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _error = 'Erreur de connexion avec Google';
      if (kDebugMode) {
        // ignore: avoid_print
        print(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'user-not-found':
        return 'Aucun compte avec cet e-mail';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet e-mail';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      default:
        return 'Une erreur est survenue';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

