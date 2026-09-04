import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart'; 

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    if (historyState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (historyState.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(historyState.errorMessage!)),
      );
    }

    final sessions = historyState.sessions;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Jejuns')),
      body: sessions.isEmpty
          ? const Center(child: Text('Nenhum jejum registrado ainda.'))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text('Protocolo ${session.protocol.name}'),
                  subtitle: Text('Duração: ${session.duration.inHours}h'),
                );
              },
            ),
    );
  }
}