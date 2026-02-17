import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/performance_entry.dart';
import '../models/training_program.dart';
import '../models/training_session.dart';
import '../services/firestore_service.dart';

class TrainingController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TrainingProgram> programs = [];
  List<TrainingSession> sessions = [];
  List<PerformanceEntry> performances = [];

  bool isLoading = false;

  void init() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestoreService.watchPrograms(user.uid).listen((data) {
      programs = data;
      notifyListeners();
    });
    _firestoreService.watchSessions(user.uid).listen((data) {
      sessions = data;
      notifyListeners();
    });
    _firestoreService.watchPerformances(user.uid).listen((data) {
      performances = data;
      notifyListeners();
    });
  }

  Future<void> saveProgram(TrainingProgram program) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestoreService.saveProgram(userId: user.uid, program: program);
  }

  Future<void> deleteProgram(String id) async {
    await _firestoreService.deleteProgram(id);
  }

  Future<void> saveSession(TrainingSession session) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestoreService.saveSession(userId: user.uid, session: session);
  }

  Future<void> savePerformance(PerformanceEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestoreService.savePerformance(userId: user.uid, entry: entry);
  }
}

