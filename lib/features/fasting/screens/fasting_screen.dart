import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/fasting_protocol.dart';
import '../../../models/fasting_session.dart';
import '../providers/fasting_provider.dart';
import '../widgets/custom_protocol_dialog.dart';
import '../widgets/fasting_timer.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  FastingProtocol? _selectedProtocol;

  late final List<FastingProtocol> _protocols = AppConstants.defaultProtocols
      .map((p) => FastingProtocol(
            id: p['name'],
            name: p['name'],
            fastingHours: p['fastingHours'],
            eatingHours: p['eatingHours'],
          ))
      .toList();

  void _handleStopFasting(FastingSession session) {
    final bool isEarlyStop = session.remainingTime > Duration.zero;

    if (isEarlyStop) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Encerrar Jejum?'),
          content: const Text('Tem certeza que deseja encerrar o jejum antes de atingir a meta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                ref.read(fastingNotifierProvider.notifier).stopFasting(isCompleted: false);
              },
              child: const Text('Encerrar', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    } else {
      ref.read(fastingNotifierProvider.notifier).stopFasting(isCompleted: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timerTickerProvider);

    final fastingState = ref.watch(fastingNotifierProvider);
    final FastingSession? session = fastingState.session;
    final bool isFasting = session?.status == 'active';

    final double progress = session?.progressPercentage ?? 0.0;
    final String timeDisplay = session != null
        ? AppDateUtils.formatDuration(session.remainingTime)
        : '00:00:00';
    final String elapsedDisplay = session != null
        ? AppDateUtils.formatDuration(session.elapsedTime)
        : '00:00:00';
    
    final canStart = _selectedProtocol != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mamba Fast', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              FastingTimer(
                progress: progress,
                remainingTime: timeDisplay,
            elapsedTime: elapsedDisplay,
                protocolName: session?.protocol.name ?? _selectedProtocol?.name ?? '16:8',
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Spacer(),
              if (!isFasting) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecione o Protocolo:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _protocols.length + 1, 
                    itemBuilder: (context, index) {
                      if (index == _protocols.length) {
                        final isCustomSelected = _selectedProtocol?.isCustom == true;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final customProtocol = await showDialog<FastingProtocol>(
                                context: context,
                                builder: (_) => const CustomProtocolDialog(),
                              );
                              if (customProtocol != null) {
                                setState(() => _selectedProtocol = customProtocol);
                              }
                            },
                            icon: Icon(Icons.add, size: 18, color: isCustomSelected ? AppColors.primary : null),
                            label: Text(
                              isCustomSelected ? _selectedProtocol!.name : 'Custom',
                              style: isCustomSelected
                                  ? const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                                  : null,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              side: BorderSide(
                                color: isCustomSelected ? AppColors.primary : Colors.grey,
                                width: isCustomSelected ? 2 : 1,
                              ),
                            ),
                          ),
                        );
                      }

                      final p = _protocols[index];
                      final isSelected = _selectedProtocol?.id == p.id;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: ActionChip(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Protocolo ${p.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primary : Colors.white,
                                ),
                              ),
                              Text('${p.fastingHours}h de jejum', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                          onPressed: () => setState(() => _selectedProtocol = p),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Opacity(
                opacity: (!isFasting && !canStart) ? 0.5 : 1.0,
                child: GradientButton(
                  text: isFasting ? 'ENCERRAR JEJUM' : 'INICIAR JEJUM',
                  isLoading: fastingState.isLoading,
                  isDestructive: isFasting,
                  onPressed: () {
                    if (isFasting) {
                      _handleStopFasting(session!);
                      return;
                    }
                    if (!canStart) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecione um protocolo para iniciar.')),
                      );
                      return;
                    }
                    ref.read(fastingNotifierProvider.notifier).startFasting(_selectedProtocol!);
                    setState(() => _selectedProtocol = null);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}