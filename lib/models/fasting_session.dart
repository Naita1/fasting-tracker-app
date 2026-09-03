import 'fasting_protocol.dart';

class FastingSession {
  final String id;
  final DateTime startedAt;
  final DateTime plannedEndAt;
  final DateTime? actualEndAt;
  final String status; 
  final FastingProtocol protocol;

  FastingSession({
    required this.id,
    required this.startedAt,
    required this.plannedEndAt,
    this.actualEndAt,
    required this.status,
    required this.protocol,
  });

  Duration get elapsedTime {
    final endTime = actualEndAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  Duration get remainingTime {
    if (status != 'active') return Duration.zero;
    final remaining = plannedEndAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progressPercentage {
    final totalDuration = plannedEndAt.difference(startedAt).inSeconds;
    if (totalDuration == 0) return 0.0;
    final elapsed = elapsedTime.inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'plannedEndAt': plannedEndAt.toIso8601String(),
      'actualEndAt': actualEndAt?.toIso8601String(),
      'status': status,
      'protocol': protocol.toMap(),
    };
  }

  factory FastingSession.fromMap(Map<String, dynamic> map) {
    return FastingSession(
      id: map['id'] ?? '',
      startedAt: DateTime.parse(map['startedAt']),
      plannedEndAt: DateTime.parse(map['plannedEndAt']),
      actualEndAt: map['actualEndAt'] != null ? DateTime.parse(map['actualEndAt']) : null,
      status: map['status'] ?? 'active',
      protocol: FastingProtocol.fromMap(Map<String, dynamic>.from(map['protocol'])),
    );
  }
}