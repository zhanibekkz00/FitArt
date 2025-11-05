class WorkoutDto {
  WorkoutDto({
    required this.id,
    required this.title,
    this.description,
    required this.level,
    this.duration,
    this.calories,
    this.exercises = const [],
  });

  final int id;
  final String title;
  final String? description;
  final String level; // backend enum serialized as string
  final int? duration;
  final int? calories;
  final List<String> exercises;

  factory WorkoutDto.fromJson(Map<String, dynamic> json) {
    final lvl = json['level'];
    final ex = json['exercises'];
    return WorkoutDto(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? json['name']) as String, // support older 'name'
      description: json['description'] as String?,
      level: (lvl is String) ? lvl : (lvl?.toString() ?? ''),
      duration: (json['duration'] as num?)?.toInt(),
      calories: (json['calories'] as num?)?.toInt(),
      exercises: ex is List ? ex.map((e) => e.toString()).toList().cast<String>() : const <String>[],
    );
  }
}


