import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/fasting_protocol.dart';
import '../providers/fasting_provider.dart';
import '../widgets/custom_protocol_dialog.dart';

class ProtocolScreen extends ConsumerWidget {
  const ProtocolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultProtocols = AppConstants.defaultProtocols
        .map((p) => FastingProtocol(
              id: p['name'],
              name: p['name'],
              fastingHours: p['fastingHours'],
              eatingHours: p['eatingHours'],
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Protocolo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...defaultProtocols.map((protocol) => Card(
                child: ListTile(
                  title: Text('Protocolo ${protocol.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${protocol.fastingHours}h de jejum / ${protocol.eatingHours}h de alimentação'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await ref.read(fastingProvider.notifier).startFasting(protocol);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final customProtocol = await showDialog<FastingProtocol>(
                context: context,
                builder: (_) => const CustomProtocolDialog(),
              );
              if (customProtocol != null) {
                await ref.read(fastingProvider.notifier).startFasting(customProtocol);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Criar Protocolo Customizado'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }
}