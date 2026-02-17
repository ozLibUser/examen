class TrainingSession {
  final String id;
  final String programId;
  final DateTime date;
  final int durationSeconds;
  final String notes;

  TrainingSession({
    required this.id,
    required this.programId,
    required this.date,
    required this.durationSeconds,
    required this.notes,
  });

  TrainingSession copyWith({
    String? id,
    String? programId,
    DateTime? date,
    int? durationSeconds,
    String? notes,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'userId': userId,
      'programId': programId,
      'date': date.toIso8601String(),
      'durationSeconds': durationSeconds,
      'notes': notes,
    };
  }

  factory TrainingSession.fromDoc(String id, Map<String, dynamic> data) {
    return TrainingSession(
      id: id,
      programId: data['programId'] as String? ?? '',
      date: DateTime.tryParse(data['date'] as String? ?? '') ??
          DateTime.now(),
      durationSeconds: data['durationSeconds'] as int? ?? 0,
      notes: data['notes'] as String? ?? '',
    );
  }
}

