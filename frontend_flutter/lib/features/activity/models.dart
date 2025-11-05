class ActivityLogDto {
  final int? id;
  final int steps;
  final int calories;
  final double sleepHours;
  final DateTime date;
  final String? notes;

  ActivityLogDto({
    this.id,
    required this.steps,
    required this.calories,
    required this.sleepHours,
    required this.date,
    this.notes,
  });

  factory ActivityLogDto.fromJson(Map<String, dynamic> json) {
    return ActivityLogDto(
      id: json['id'] as int?,
      steps: (json['steps'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      sleepHours: (json['sleepHours'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'steps': steps,
      'calories': calories,
      'sleepHours': sleepHours,
      'date': formatDate(date),
      if (notes != null) 'notes': notes,
    };
  }

  static String formatDate(DateTime d) {
    // Format yyyy-MM-dd to match Spring LocalDate
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

class WaterEntryDto {
  final int? id;
  final String date; // yyyy-MM-dd
  final int milliliters;

  WaterEntryDto({this.id, required this.date, required this.milliliters});

  factory WaterEntryDto.fromJson(Map<String, dynamic> json) => WaterEntryDto(
        id: (json['id'] as num?)?.toInt(),
        date: json['date'] as String,
        milliliters: (json['milliliters'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'date': date,
        'milliliters': milliliters,
      };
}

class NutritionEntryDto {
  final int? id;
  final String date; // yyyy-MM-dd
  final String food;
  final int calories;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;

  NutritionEntryDto({
    this.id,
    required this.date,
    required this.food,
    required this.calories,
    this.proteinG,
    this.fatG,
    this.carbsG,
  });

  factory NutritionEntryDto.fromJson(Map<String, dynamic> json) => NutritionEntryDto(
        id: (json['id'] as num?)?.toInt(),
        date: json['date'] as String,
        food: json['food'] as String,
        calories: (json['calories'] as num).toInt(),
        proteinG: (json['proteinG'] as num?)?.toDouble(),
        fatG: (json['fatG'] as num?)?.toDouble(),
        carbsG: (json['carbsG'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'date': date,
        'food': food,
        'calories': calories,
        if (proteinG != null) 'proteinG': proteinG,
        if (fatG != null) 'fatG': fatG,
        if (carbsG != null) 'carbsG': carbsG,
      };
}
