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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.cancel,
          color: isCompleted ? AppColors.primary : AppColors.error,
          size: 32,
        ),
        title: Text('Protocolo ${session.protocol.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Início: ${AppDateUtils.formatDate(session.startedAt)} - ${AppDateUtils.formatTime(session.startedAt)}',
        ),
        trailing: Text(
          AppDateUtils.formatDuration(session.elapsedTime),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}