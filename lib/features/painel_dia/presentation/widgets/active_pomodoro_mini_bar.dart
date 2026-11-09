import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pomodoro_timer_state.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/pomodoro_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/pomodoro_player_sheet.dart';

/// Barra flutuante na base do Painel do Dia exibida quando há um ciclo Pomodoro ativo minimizado (`E04-T05`).
///
/// Permite pausar/retomar em 1 toque e reabrir o player em tela cheia ao ser tocada.
class ActivePomodoroMiniBar extends ConsumerWidget {
  const ActivePomodoroMiniBar({super.key});

  void _abrirPlayer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PomodoroPlayerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PomodoroTimerState timerState = ref.watch(pomodoroNotifierProvider);

    if (!timerState.isActive) {
      return const SizedBox.shrink();
    }

    final PomodoroNotifier notifier =
        ref.read(pomodoroNotifierProvider.notifier);
    final Color pilarColor = AppColors.fromHex(timerState.corPilarHex);

    return Container(
      key: const Key('active_pomodoro_mini_bar'),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: pilarColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _abrirPlayer(context),
          borderRadius: AppSpacing.cardRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: <Widget>[
                // Mini indicador circular
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        value: timerState.progress,
                        strokeWidth: 3.5,
                        backgroundColor: pilarColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(pilarColor),
                      ),
                      Icon(
                        timerState.isRunning
                            ? Icons.local_fire_department_rounded
                            : Icons.pause_rounded,
                        size: 14,
                        color: pilarColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Nome da Tarefa e Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        timerState.nomeTarefa,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        timerState.isRunning
                            ? 'Foco em andamento'
                            : 'Temporizador pausado',
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contador Tabular MM:SS
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    timerState.tempoFormatado,
                    key: const Key('mini_bar_countdown_text'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontFeatures: <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),

                // Botão Rápido Play/Pause
                IconButton(
                  key: const Key('mini_bar_play_pause_btn'),
                  icon: Icon(
                    timerState.isRunning
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: pilarColor,
                    size: 28,
                  ),
                  onPressed: () {
                    if (timerState.isRunning) {
                      notifier.pause();
                    } else {
                      notifier.resume();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
