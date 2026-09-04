import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../fasting/providers/fasting_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(fastingRepositoryProvider).getHistory();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Jejum')),
      body: history.isEmpty
          ? const Center(
              child: Text('Nenhum histórico encontrado.',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];
                final isCompleted = session.status == 'completed';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      isCompleted ? Icons.check_circle : Icons.cancel,
                      color: isCompleted ? AppColors.primary : AppColors.error,
                      size: 32,
                    ),
                    title: Text('Protocolo ${session.protocol.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Início: ${AppDateUtils.formatDate(session.startedAt)} - ${AppDateUtils.formatTime(session.startedAt)}',
                    ),
                    trailing: Text(
                      AppDateUtils.formatDuration(session.elapsedTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }
}