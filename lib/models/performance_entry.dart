class PerformanceEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final String note;

  PerformanceEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.note,
  });

  PerformanceEntry copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    String? note,
  }) {
    return PerformanceEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'note': note,
    };
  }

  factory PerformanceEntry.fromDoc(String id, Map<String, dynamic> data) {
    return PerformanceEntry(
      id: id,
      date: DateTime.tryParse(data['date'] as String? ?? '') ??
          DateTime.now(),
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      note: data['note'] as String? ?? '',
    );
  }
}

