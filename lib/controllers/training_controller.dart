import 'dart:async';

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
  String? _error;

  StreamSubscription<List<TrainingProgram>>? _programsSub;
  StreamSubscription<List<TrainingSession>>? _sessionsSub;
  StreamSubscription<List<PerformanceEntry>>? _performancesSub;

  String? get error => _error;

  void init() {
    final user = _auth.currentUser;
    if (user == null) return;

    _cancelSubscriptions();
    programs = [];
    sessions = [];
    performances = [];
    _error = null;

    _programsSub = _firestoreService.watchPrograms(user.uid).listen(
      (data) {
        programs = data;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) print('[TrainingController] programs stream error: $e');
        _error = 'Erreur chargement programmes';
        notifyListeners();
      },
    );
    _sessionsSub = _firestoreService.watchSessions(user.uid).listen(
      (data) {
        sessions = data;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) print('[TrainingController] sessions stream error: $e');
        _error = 'Erreur chargement séances';
        notifyListeners();
      },
    );
    _performancesSub = _firestoreService.watchPerformances(user.uid).listen(
      (data) {
        performances = data;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) print('[TrainingController] performances stream error: $e');
        _error = 'Erreur chargement performances';
        notifyListeners();
      },
    );
  }

  void _cancelSubscriptions() {
    _programsSub?.cancel();
    _sessionsSub?.cancel();
    _performancesSub?.cancel();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> saveProgram(TrainingProgram program) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _firestoreService.saveProgram(userId: user.uid, program: program);
      return true;
    } catch (e) {
      if (kDebugMode) print('[TrainingController] saveProgram error: $e');
      _error = 'Erreur enregistrement';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgram(String id) async {
    try {
      await _firestoreService.deleteProgram(id);
      return true;
    } catch (e) {
      if (kDebugMode) print('[TrainingController] deleteProgram error: $e');
      _error = 'Erreur suppression';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveSession(TrainingSession session) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _firestoreService.saveSession(userId: user.uid, session: session);
      return true;
    } catch (e) {
      if (kDebugMode) print('[TrainingController] saveSession error: $e');
      _error = 'Erreur enregistrement séance';
      notifyListeners();
      return false;
    }
  }

  Future<bool> savePerformance(PerformanceEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _firestoreService.savePerformance(userId: user.uid, entry: entry);
      return true;
    } catch (e) {
      if (kDebugMode) print('[TrainingController] savePerformance error: $e');
      _error = 'Erreur enregistrement';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePerformance(String id) async {
    try {
      await _firestoreService.deletePerformance(id);
      return true;
    } catch (e) {
      if (kDebugMode) print('[TrainingController] deletePerformance error: $e');
      _error = 'Erreur suppression';
      notifyListeners();
      return false;
    }
  }

  void dispose() {
    _cancelSubscriptions();
  }
}

