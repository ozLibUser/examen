// TODO: Remplacer ces valeurs par la configuration générée
// via `flutterfire configure` pour votre projet Firebase.
//
// Ce fichier est uniquement là pour permettre la compilation
// et illustrer l’intégration Firebase demandée dans l’examen.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'WEB_API_KEY',
        appId: 'WEB_APP_ID',
        messagingSenderId: 'WEB_MESSAGING_SENDER_ID',
        projectId: 'WEB_PROJECT_ID',
      );
    }

    // Android par défaut (mobile)
    return const FirebaseOptions(
      apiKey: 'ANDROID_API_KEY',
      appId: 'ANDROID_APP_ID',
      messagingSenderId: 'ANDROID_MESSAGING_SENDER_ID',
      projectId: 'ANDROID_PROJECT_ID',
    );
  }
}

