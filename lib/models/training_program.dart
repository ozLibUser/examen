class TrainingProgram {
  final String id;
  final String name;
  final String description;
  final String level; // ex: Débutant / Intermédiaire / Avancé

  TrainingProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
  });

  factory TrainingProgram.empty() => TrainingProgram(
        id: '',
        name: '',
        description: '',
        level: 'Débutant',
      );

  TrainingProgram copyWith({
    String? id,
    String? name,
    String? description,
    String? level,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'level': level,
    };
  }

  factory TrainingProgram.fromDoc(String id, Map<String, dynamic> data) {
    return TrainingProgram(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      level: data['level'] as String? ?? 'Débutant',
    );
  }
}

