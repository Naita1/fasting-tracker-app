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
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}