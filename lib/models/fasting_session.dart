import 'fasting_protocol.dart';

class FastingSession {
  final String id;
  final DateTime startedAt;
  final DateTime plannedEndAt;
  final DateTime? actualEndAt;
  final String status; // 'active' | 'paused' | 'completed' | 'cancelled'
  final FastingProtocol protocol;
  final DateTime? pausedAt;
  final Duration accumulatedPausedDuration;

  const FastingSession({
    required this.id,
    required this.startedAt,
    required this.plannedEndAt,
    this.actualEndAt,
    required this.status,
    required this.protocol,
    this.pausedAt,
    this.accumulatedPausedDuration = Duration.zero,
  });

  bool get isPaused => status == 'paused';
  bool get isActive => status == 'active';

  DateTime get _referenceNow {
    if (isPaused && pausedAt != null) return pausedAt!;
    return actualEndAt ?? DateTime.now();
  }

  Duration get elapsedTime {
    final raw = _referenceNow.difference(startedAt);
    final effective = raw - accumulatedPausedDuration;
    return effective.isNegative ? Duration.zero : effective;
  }

  Duration get remainingTime {
    if (status == 'completed' || status == 'cancelled') return Duration.zero;
    final totalPlanned = plannedEndAt.difference(startedAt);
    final remaining = totalPlanned - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progressPercentage {
    final totalDuration = plannedEndAt.difference(startedAt).inSeconds;
    if (totalDuration <= 0) return 0.0;
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
      'pausedAt': pausedAt?.toIso8601String(),
      'accumulatedPausedSeconds': accumulatedPausedDuration.inSeconds,
    };
  }

  factory FastingSession.fromMap(Map<String, dynamic> map) {
    return FastingSession(
      id: map['id']?.toString() ?? '',
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'].toString())
          : DateTime.now(),
      plannedEndAt: map['plannedEndAt'] != null
          ? DateTime.parse(map['plannedEndAt'].toString())
          : DateTime.now().add(const Duration(hours: 16)),
      actualEndAt: map['actualEndAt'] != null
          ? DateTime.parse(map['actualEndAt'].toString())
          : null,
      status: map['status']?.toString() ?? 'active',
      protocol: map['protocol'] != null
          ? FastingProtocol.fromMap(Map<String, dynamic>.from(map['protocol']))
          : const FastingProtocol(
              id: '16-8',
              name: '16:8',
              fastingHours: 16,
              eatingHours: 8,
            ),
      pausedAt: map['pausedAt'] != null
          ? DateTime.parse(map['pausedAt'].toString())
          : null,
      accumulatedPausedDuration:
          Duration(seconds: (map['accumulatedPausedSeconds'] as num?)?.toInt() ?? 0),
    );
  }

  FastingSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? plannedEndAt,
    DateTime? actualEndAt,
    String? status,
    FastingProtocol? protocol,
    DateTime? Function()? pausedAt,
    Duration? accumulatedPausedDuration,
  }) {
    return FastingSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      plannedEndAt: plannedEndAt ?? this.plannedEndAt,
      actualEndAt: actualEndAt ?? this.actualEndAt,
      status: status ?? this.status,
      protocol: protocol ?? this.protocol,
      pausedAt: pausedAt != null ? pausedAt() : this.pausedAt,
      accumulatedPausedDuration: accumulatedPausedDuration ?? this.accumulatedPausedDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastingSession &&
        other.id == id &&
        other.startedAt == startedAt &&
        other.plannedEndAt == plannedEndAt &&
        other.actualEndAt == actualEndAt &&
        other.status == status &&
        other.protocol == protocol &&
        other.pausedAt == pausedAt &&
        other.accumulatedPausedDuration == accumulatedPausedDuration;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        startedAt.hashCode ^
        plannedEndAt.hashCode ^
        actualEndAt.hashCode ^
        status.hashCode ^
        protocol.hashCode ^
        pausedAt.hashCode ^
        accumulatedPausedDuration.hashCode;
  }

  @override
  String toString() {
    return 'FastingSession(id: $id, status: $status, protocol: ${protocol.name}, startedAt: $startedAt)';
  }
}