class FastingProtocol {
  final String id;
  final String name;
  final int fastingHours;
  final int eatingHours;
  final bool isCustom;

  FastingProtocol({
    required this.id,
    required this.name,
    required this.fastingHours,
    required this.eatingHours,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fastingHours': fastingHours,
      'eatingHours': eatingHours,
      'isCustom': isCustom,
    };
  }

  factory FastingProtocol.fromMap(Map<String, dynamic> map) {
    return FastingProtocol(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      fastingHours: map['fastingHours'] ?? 16,
      eatingHours: map['eatingHours'] ?? 8,
      isCustom: map['isCustom'] ?? false,
    );
  }
}