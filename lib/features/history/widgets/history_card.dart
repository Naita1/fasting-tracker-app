import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/fasting_session.dart';

class HistoryCard extends StatelessWidget {
  final FastingSession session;

  const HistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == 'completed';
    final startTime = AppDateUtils.formatTime(session.startedAt);
    final endTime = session.actualEndAt != null
        ? AppDateUtils.formatTime(session.actualEndAt!)
        : '--:--';

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          isThreeline: true,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCompleted ? AppColors.primary : AppColors.error).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.cancel,
              color: isCompleted ? AppColors.primary : AppColors.error,
              size: 24,
            ),
          ),
          title: Text(
            'Protocolo ${session.protocol.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${AppDateUtils.formatDate(session.startedAt)}\n$startTime - $endTime',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          trailing: Text(
            AppDateUtils.formatDuration(session.elapsedTime),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}