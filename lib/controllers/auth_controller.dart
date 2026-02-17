import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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
      // Évite "setState during build" : notifier après le frame en cours
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthController] signInWithEmail: $email');
    }
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        await _ensureUserInFirestore(user);
        if (kDebugMode) {
          // ignore: avoid_print
          print('[AuthController] signInWithEmail OK');
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signInWithEmail FirebaseAuthException: ${e.code} - ${e.message}');
      }
      _error = _authErrorMessage(e.code);
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signInWithEmail error: $e');
        // ignore: avoid_print
        print(st);
      }
      _error = 'Erreur de connexion';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthController] signUpWithEmail: $email');
    }
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        await _ensureUserInFirestore(user);
        if (kDebugMode) {
          // ignore: avoid_print
          print('[AuthController] signUpWithEmail OK');
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signUpWithEmail FirebaseAuthException: ${e.code} - ${e.message}');
      }
      _error = _authErrorMessage(e.code);
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signUpWithEmail error: $e');
        // ignore: avoid_print
        print(st);
      }
      _error = 'Erreur lors de l\'inscription';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthController] signInWithGoogle');
    }
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        await _ensureUserInFirestore(user);
        if (kDebugMode) {
          // ignore: avoid_print
          print('[AuthController] signInWithGoogle OK: ${user.uid}');
        }
        notifyListeners();
        return true;
      }
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signInWithGoogle: user cancelled');
      }
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] signInWithGoogle error: $e');
        // ignore: avoid_print
        print(st);
      }
      _error = 'Erreur de connexion avec Google';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _ensureUserInFirestore(User user) async {
    try {
      await _firestoreService.saveUser(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] User saved to Firestore: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[AuthController] Failed to save user to Firestore: $e');
      }
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

