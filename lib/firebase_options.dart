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
        apiKey: 'AIzaSyB1S5zw95PY1BDGk11qya-luDdqEph4xPk',
        authDomain: 'examen-fb32c.firebaseapp.com',
        projectId: 'examen-fb32c',
        storageBucket: 'examen-fb32c.firebasestorage.app',
        messagingSenderId: '798157208423',
        appId: '1:798157208423:web:29a73aaaac1f4f4a548dc2',
        measurementId: 'G-8HFNGE4X29',
      );
    }

    // Android (mêmes valeurs web par défaut)
    return const FirebaseOptions(
      apiKey: 'AIzaSyB1S5zw95PY1BDGk11qya-luDdqEph4xPk',
      authDomain: 'examen-fb32c.firebaseapp.com',
      projectId: 'examen-fb32c',
      storageBucket: 'examen-fb32c.firebasestorage.app',
      messagingSenderId: '798157208423',
      appId: '1:798157208423:web:29a73aaaac1f4f4a548dc2',
    );
  }
}

