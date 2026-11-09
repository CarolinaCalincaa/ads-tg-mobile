import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';
import 'package:produtividade_tcc/features/alertas/presentation/providers/lembretes_notifier.dart';
import 'package:produtividade_tcc/features/alertas/presentation/widgets/reminder_config_card.dart';

/// Aba 3: Tela de Alertas Saudáveis e Lembretes de Saúde Cognitiva (`RF21`).
class AlertasScreen extends ConsumerWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LembretesState state = ref.watch(lembretesNotifierProvider);
    final LembretesNotifier notifier = ref.read(lembretesNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas Saudáveis (RF21)'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.loadLembretes,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              // Cabeçalho explicativo
              Text(
                'Lembretes de Saúde Cognitiva',
                style: AppTypography.displayTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'Notificações locais discretas para proteger seu cérebro da exaustão, fadiga postural e privação de sono.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (state.isLoading && state.configs.isEmpty)
                const Center(child: CircularProgressIndicator())
              else ...<Widget>[
                for (final LembreteConfigEntity config in state.configs) ...<Widget>[
                  ReminderConfigCard(
                    config: config,
                    onToggleAtivo: (ativo) =>
                        notifier.toggleAtivo(config.tipo, ativo),
                    onUpdateConfig: (updated) =>
                        notifier.updateConfig(updated),
                    onTestarAlerta: () async {
                      await notifier.testarLembrete(config.tipo);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Notificação de teste disparada: "${config.titulo}"',
                            ),
                            backgroundColor: AppColors.primaryBrand,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
