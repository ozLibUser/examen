import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/performance_entry.dart';
import '../models/training_program.dart';
import '../models/training_session.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _programsRef() =>
      _db.collection('programs');

  CollectionReference<Map<String, dynamic>> _sessionsRef() =>
      _db.collection('sessions');

  CollectionReference<Map<String, dynamic>> _performancesRef() =>
      _db.collection('performances');

  // PROGRAMMES ---------------------------------------------------------------

  Future<void> saveProgram({
    required String userId,
    required TrainingProgram program,
  }) async {
    if (program.id.isEmpty) {
      await _programsRef().add(program.toMap(userId: userId));
    } else {
      await _programsRef()
          .doc(program.id)
          .update(program.toMap(userId: userId));
    }
  }

  Future<void> deleteProgram(String id) async {
    await _programsRef().doc(id).delete();
  }

  Stream<List<TrainingProgram>> watchPrograms(String userId) {
    return _programsRef()
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) =>
                  TrainingProgram.fromDoc(doc.id, doc.data()),
            )
            .toList();
      },
    );
  }

  // SESSIONS -----------------------------------------------------------------

  Future<void> saveSession({
    required String userId,
    required TrainingSession session,
  }) async {
    if (session.id.isEmpty) {
      await _sessionsRef().add(session.toMap(userId: userId));
    } else {
      await _sessionsRef()
          .doc(session.id)
          .update(session.toMap(userId: userId));
    }
  }

  Stream<List<TrainingSession>> watchSessions(String userId) {
    return _sessionsRef()
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => TrainingSession.fromDoc(
                doc.id,
                doc.data(),
              ),
            )
            .toList();
      },
    );
  }

  // PERFORMANCES -------------------------------------------------------------

  Future<void> savePerformance({
    required String userId,
    required PerformanceEntry entry,
  }) async {
    if (entry.id.isEmpty) {
      await _performancesRef().add(entry.toMap(userId: userId));
    } else {
      await _performancesRef()
          .doc(entry.id)
          .update(entry.toMap(userId: userId));
    }
  }

  Stream<List<PerformanceEntry>> watchPerformances(String userId) {
    return _performancesRef()
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => PerformanceEntry.fromDoc(
                doc.id,
                doc.data(),
              ),
            )
            .toList();
      },
    );
  }
}

