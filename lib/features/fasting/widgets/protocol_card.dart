import 'package:flutter/material.dart';
import '../../../models/fasting_protocol.dart';

class ProtocolCard extends StatelessWidget {
  final FastingProtocol protocol;
  final VoidCallback onTap;

  const ProtocolCard({super.key, required this.protocol, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Protocolo ${protocol.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${protocol.fastingHours}h de jejum / ${protocol.eatingHours}h de alimentação'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}