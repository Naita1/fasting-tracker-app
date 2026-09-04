class Meal {
  final String id;
  final String name;
  final int calories;
  final DateTime dateTime;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : DateTime.now(),
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    int? calories,
    DateTime? dateTime,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meal &&
        other.id == id &&
        other.name == name &&
        other.calories == calories &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ calories.hashCode ^ dateTime.hashCode;
}