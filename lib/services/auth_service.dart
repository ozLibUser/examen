import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/auth_config.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _googleSignInOrCreate =>
      _googleSignIn ??= GoogleSignIn(
        clientId: kIsWeb ? AuthConfig.webClientId : null,
      );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web : utilise signInWithPopup de Firebase (plus fiable, gère les redirects)
      try {
        final credential = await _firebaseAuth.signInWithPopup(
          GoogleAuthProvider(),
        );
        if (kDebugMode) {
          // ignore: avoid_print
          print('[AuthService] signInWithPopup OK: ${credential.user?.uid}');
        }
        return credential.user;
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[AuthService] signInWithPopup error: $e');
        }
        rethrow;
      }
    }

    // Mobile : google_sign_in + signInWithCredential
    await _googleSignInOrCreate.signOut();
    final googleUser = await _googleSignInOrCreate.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthService] signInWithEmailAndPassword: $email');
    }
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthService] signIn OK: ${userCredential.user?.uid}');
    }
    return userCredential.user;
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthService] createUserWithEmailAndPassword: $email');
    }
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AuthService] signUp OK: ${userCredential.user?.uid}');
    }
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
  }
}

