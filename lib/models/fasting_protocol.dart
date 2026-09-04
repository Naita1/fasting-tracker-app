class FastingProtocol {
  final String id;
  final String name;
  final int fastingHours;
  final int eatingHours;
  final bool isCustom;
  final String? description;

  const FastingProtocol({
    required this.id,
    required this.name,
    required this.fastingHours,
    required this.eatingHours,
    this.isCustom = false,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fastingHours': fastingHours,
      'eatingHours': eatingHours,
      'isCustom': isCustom,
      'description': description,
    };
  }

  factory FastingProtocol.fromMap(Map<String, dynamic> map) {
    final fasting = (map['fastingHours'] as num?)?.toInt() ?? 16;
    final eating = (map['eatingHours'] as num?)?.toInt() ?? (24 - fasting);

    return FastingProtocol(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      fastingHours: fasting,
      eatingHours: eating,
      isCustom: map['isCustom'] as bool? ?? false,
      description: map['description']?.toString(),
    );
  }

  FastingProtocol copyWith({
    String? id,
    String? name,
    int? fastingHours,
    int? eatingHours,
    bool? isCustom,
    String? description,
  }) {
    return FastingProtocol(
      id: id ?? this.id,
      name: name ?? this.name,
      fastingHours: fastingHours ?? this.fastingHours,
      eatingHours: eatingHours ?? this.eatingHours,
      isCustom: isCustom ?? this.isCustom,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastingProtocol &&
        other.id == id &&
        other.name == name &&
        other.fastingHours == fastingHours &&
        other.eatingHours == eatingHours &&
        other.isCustom == isCustom &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        fastingHours.hashCode ^
        eatingHours.hashCode ^
        isCustom.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'FastingProtocol(id: $id, name: $name, fastingHours: $fastingHours, eatingHours: $eatingHours, isCustom: $isCustom, description: $description)';
  }
}