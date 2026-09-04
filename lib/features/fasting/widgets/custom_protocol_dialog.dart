import 'package:flutter/material.dart';
import '../../../models/fasting_protocol.dart';

class CustomProtocolDialog extends StatefulWidget {
  const CustomProtocolDialog({super.key});

  @override
  State<CustomProtocolDialog> createState() => _CustomProtocolDialogState();
}

class _CustomProtocolDialogState extends State<CustomProtocolDialog> {
  final _fastingHoursController = TextEditingController(text: '14');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Protocolo Customizado'),
      content: TextField(
        controller: _fastingHoursController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Horas de Jejum',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = int.tryParse(_fastingHoursController.text) ?? 12;
            final protocol = FastingProtocol(
              id: 'custom_$hours',
              name: '$hours:${24 - hours}',
              fastingHours: hours,
              eatingHours: 24 - hours,
              isCustom: true,
            );
            Navigator.pop(context, protocol);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}