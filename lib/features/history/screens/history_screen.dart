import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Jejum')),
      body: _buildBody(historyState),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum histórico encontrado.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        return HistoryCard(session: state.sessions[index]);
      },    
    );
  }
}