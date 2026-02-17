## Suivi d’Entraînement Sportif – Journal de bord

Application Flutter réalisée dans le cadre de l’examen de Programmation Mobile L4 LMD.

### Sujet choisi

- **Sujet 11 : Suivi d’Entraînement Sportif**
- **But**: Journal de bord sportif.
- **Fonctionnalités implémentées**:
  - **Création / édition / suppression de programmes d’entraînement**
  - **Chronomètre intégré** pour mesurer la durée d’une séance
  - **Log des séances** (date, durée, notes)
  - **Suivi du poids / performances** (enregistrement du poids + note / performance)

### Socle technique demandé par l’énoncé

- **Framework**: Flutter
- **Architecture**: Pattern **MVC** avec séparation claire :
  - `lib/models` : modèles (`TrainingProgram`, `TrainingSession`, `PerformanceEntry`)
  - `lib/views` : écrans et UI (`auth`, `home`, etc.)
  - `lib/controllers` : logique métier et gestion d’état (`AuthController`, `TrainingController`)
  - `lib/services` : accès Firebase & API externe (`AuthService`, `FirestoreService`, `ExternalApiService`)
- **Gestion d’état**: package **provider**
- **Base de données**: **Cloud Firestore** (CRUD complet sur programmes, séances et mesures de performances)
- **Authentification**: **Firebase Auth** avec **provider externe Google** (seul provider externe demandé)
- **API REST externe**: consommation d’une API publique de citations via `ExternalApiService`

### Pile technologique (pubspec.yaml)

Principales dépendances utilisées :

- **firebase_core**
- **firebase_auth**
- **cloud_firestore**
- **google_sign_in**
- **provider**
- **http**

### Structure des données (Firestore)

- Collection `programs`
  - `userId`
  - `name`
  - `description`
  - `level` (Débutant / Intermédiaire / Avancé)
- Collection `sessions`
  - `userId`
  - `programId` (optionnel dans cette implémentation)
  - `date`
  - `durationSeconds`
  - `notes`
- Collection `performances`
  - `userId`
  - `date`
  - `weightKg`
  - `note`

### Authentification (Firebase Auth + Google)

- L’application démarre sur un **écran de connexion** (`LoginScreen`).
- Seul le **login Google** est implémenté, via `AuthService` et `AuthController`.
- Une fois connecté, l’utilisateur est redirigé vers le **Home** (`HomeShell`) :
  - **Onglet Programmes** : gestion des programmes d’entraînement
  - **Onglet Séances** : chronomètre + historique des séances
  - **Onglet Poids & perf** : saisie et historique des mesures

### Chronomètre & log des séances

- L’onglet **Séances** contient :
  - Un **chronomètre** (start / pause / reset)
  - Un bouton **“Enregistrer la séance”** qui crée un document Firestore dans `sessions`
    avec la durée mesurée et des notes facultatives.

### Suivi du poids / performances

- L’onglet **Poids & perf** permet :
  - La saisie du **poids (kg)** et d’une petite **note/performance**
  - L’enregistrement dans la collection `performances`
  - L’affichage de l’historique des mesures sous forme de liste.

  [https://console.cloud.google.com/auth/clients/create?previousPage=%2Fapis%2Fcredentials%3Fauthuser%3D2%26project%3Dexamen-fb32c&authuser=2&project=examen-fb32c]

### Mise en place de Firebase (à faire avant de lancer l’appli)

1. **Créer un projet Firebase** sur la console Firebase.
2. **Activer Firebase Authentication** :
   - Activer le provider **Google**.
3. **Activer Cloud Firestore** en mode production ou test.
4. **Configurer FlutterFire** dans le projet :
   - Installer l’outil CLI : `dart pub global activate flutterfire_cli`
   - Dans le dossier du projet : `flutterfire configure`
   - Cela génèrera un `firebase_options.dart` avec les vraies valeurs.
5. **Remplacer** le contenu de `lib/firebase_options.dart` par celui généré automatiquement
   par FlutterFire (le fichier actuel contient des valeurs de démonstration).
6. Ajouter les fichiers de configuration natifs :
   - `google-services.json` (Android) et/ ou `GoogleService-Info.plist` (iOS) selon la plateforme.

### Lancer le projet

```bash
flutter pub get
flutter run
```

Assurez-vous d’avoir configuré Firebase avant d’exécuter l’application, sinon la connexion et Firestore ne fonctionneront pas correctement.

