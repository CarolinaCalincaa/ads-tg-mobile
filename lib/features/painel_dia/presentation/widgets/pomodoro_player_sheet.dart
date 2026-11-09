import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pomodoro_timer_state.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/pomodoro_notifier.dart';

/// Modal do reprodutor do Temporizador Pomodoro (`E04-T05` e `RF16`).
///
/// Apresenta anel circular de progresso, contador tabular regressivo `MM:SS` (ex.: `25:00`),
/// controles táteis de Iniciar/Pausar/Retomar/Reiniciar e Concluir Ciclo.
class PomodoroPlayerSheet extends ConsumerWidget {
  const PomodoroPlayerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PomodoroTimerState timerState = ref.watch(pomodoroNotifierProvider);
    final PomodoroNotifier notifier =
        ref.read(pomodoroNotifierProvider.notifier);
    final Color pilarColor = AppColors.fromHex(timerState.corPilarHex);

    return Container(
      key: const Key('pomodoro_player_sheet'),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Alça de arraste
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Cabeçalho com Pilar e botão minimizar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (timerState.nomePilar.isNotEmpty)
                PilarChip(
                  nome: timerState.nomePilar,
                  corHex: timerState.corPilarHex,
                  corFundoHex: timerState.corFundoHex,
                )
              else
                const SizedBox.shrink(),
              IconButton(
                key: const Key('minimizar_pomodoro_btn'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Minimizar',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Título da Tarefa
          Text(
            timerState.nomeTarefa.isNotEmpty
                ? timerState.nomeTarefa
                : 'Sessão de Foco',
            key: const Key('pomodoro_task_title'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.displayLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Anel Circular de Progresso + Temporizador Central Tabular
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Anel de fundo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pilarColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                // Anel de progresso ativo
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: timerState.progress,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(pilarColor),
                  ),
                ),

                // Contador Tabular MM:SS
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      timerState.tempoFormatado,
                      key: const Key('pomodoro_countdown_text'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFeatures: <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      switch (timerState.status) {
                        PomodoroStatus.running => 'Foco Ativo',
                        PomodoroStatus.paused => 'Pausado',
                        PomodoroStatus.completed => 'Ciclo Concluído!',
                        PomodoroStatus.idle => 'Pronto',
                      },
                      style: AppTypography.chipLabel.copyWith(
                        color: timerState.isRunning
                            ? pilarColor
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Botões de Controle de Fluxo
          if (timerState.isCompleted) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.capacityHealthy.withValues(alpha: 0.1),
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(
                  color: AppColors.capacityHealthy.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.capacityHealthy,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Parabéns! 25 minutos concluídos.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.capacityHealthy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: const Key('pomodoro_reiniciar_apos_concluir_btn'),
              onPressed: () {
                notifier.reset();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Fechar'),
              style: FilledButton.styleFrom(
                backgroundColor: pilarColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ] else ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Botão Reiniciar
                if (timerState.isActive)
                  IconButton.filledTonal(
                    key: const Key('pomodoro_reset_btn'),
                    onPressed: () => notifier.reset(),
                    icon: const Icon(Icons.replay_rounded),
                    tooltip: 'Reiniciar',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                    ),
                  ),
                if (timerState.isActive) const SizedBox(width: AppSpacing.md),

                // Botão Principal: Play / Pause / Resume
                if (timerState.isRunning)
                  FilledButton.icon(
                    key: const Key('pomodoro_pause_btn'),
                    onPressed: () => notifier.pause(),
                    icon: const Icon(Icons.pause_rounded, size: 24),
                    label: const Text('Pausar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.capacityWarning,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  )
                else if (timerState.isPaused)
                  FilledButton.icon(
                    key: const Key('pomodoro_resume_btn'),
                    onPressed: () => notifier.resume(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('Retomar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: pilarColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  )
                else
                  FilledButton.icon(
                    key: const Key('pomodoro_start_btn'),
                    onPressed: () {
                      notifier.resume();
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text('Iniciar Foco'),
                    style: FilledButton.styleFrom(
                      backgroundColor: pilarColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),

                if (timerState.isActive) const SizedBox(width: AppSpacing.md),

                // Botão Concluir Ciclo Antecipado
                if (timerState.isActive)
                  IconButton.filledTonal(
                    key: const Key('pomodoro_complete_early_btn'),
                    onPressed: () => notifier.completeEarly(),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.capacityHealthy,
                    ),
                    tooltip: 'Concluir Ciclo',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
