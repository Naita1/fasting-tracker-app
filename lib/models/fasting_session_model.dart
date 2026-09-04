class FastingSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int targetHours;
  final bool isCompleted;

  FastingSessionModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetHours,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetHours': targetHours,
      'isCompleted': isCompleted,
    };
  }

  factory FastingSessionModel.fromMap(Map<String, dynamic> map) {
    return FastingSessionModel(
      id: map['id'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      targetHours: map['targetHours'] ?? 16,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}