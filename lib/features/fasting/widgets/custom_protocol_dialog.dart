import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/fasting_protocol.dart';

class CustomProtocolDialog extends StatefulWidget {
  const CustomProtocolDialog({super.key});

  @override
  State<CustomProtocolDialog> createState() => _CustomProtocolDialogState();
}

class _CustomProtocolDialogState extends State<CustomProtocolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fastingHoursController = TextEditingController(text: '14');

  @override
  void dispose() {
    _fastingHoursController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final hours = int.parse(_fastingHoursController.text);
      final protocol = FastingProtocol(
        id: 'custom_$hours',
        name: '$hours:${24 - hours}',
        fastingHours: hours,
        eatingHours: 24 - hours,
        isCustom: true,
      );
      Navigator.pop(context, protocol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Protocolo Customizado'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _fastingHoursController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            labelText: 'Horas de Jejum',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            final hours = int.tryParse(value);
            if (hours == null) {
              return 'Valor inválido';
            }
            if (hours < 1 || hours > 23) {
              return 'Entre 1 e 23 horas';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _handleConfirm,
          child: const Text('CONFIRMAR'),
        ),
      ],
    );
  }
}