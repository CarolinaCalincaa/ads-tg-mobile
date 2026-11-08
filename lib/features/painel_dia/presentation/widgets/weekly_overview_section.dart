import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';

class WeeklyOverviewSection extends ConsumerWidget {
  const WeeklyOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PainelSemanaBundle? semana =
        ref.watch(painelDiaNotifierProvider).semanaBundle;

    if (semana == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Visão da Semana (${semana.inicioSemana} a ${semana.fimSemana})',
              style: AppTypography.sectionTitle,
            ),
          ),
          ...semana.dias.map((dia) {
            final Color barColor = dia.capacidadeDia.emAlertaFadiga
                ? AppColors.fatigueCritical
                : (dia.capacidadeDia.nivel == NivelFadiga.atencao
                    ? AppColors.capacityWarning
                    : AppColors.capacityHealthy);

            final double fraction =
                (dia.capacidadeDia.percentualOcupacao / 100).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () {
                  final DateTime parsed = DateTime.parse(dia.data);
                  ref.read(selectedDateProvider.notifier).setDate(parsed);
                  ref
                      .read(painelDiaNotifierProvider.notifier)
                      .setVisaoModo(VisaoModo.dia);
                },
                borderRadius: AppSpacing.cardRadius,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dia.diaSemanaNome.substring(0, 3),
                                  style: AppTypography.chipLabel.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${dia.diaSemanaNome} • ${dia.data.substring(8, 10)}',
                                    style: AppTypography.cardTitle,
                                  ),
                                  Text(
                                    'Tarefas: ${dia.tarefasConcluidas}/${dia.totalTarefas} • Hábitos: ${dia.habitosConcluidos}/${dia.totalHabitos}',
                                    style: AppTypography.chipLabel.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${dia.capacidadeDia.percentualOcupacao}%',
                                style: AppTypography.cardTitle.copyWith(
                                  color: barColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${dia.capacidadeDia.minutosComprometidos} / ${dia.capacidadeDia.limiteFadigaMinutos} min',
                                style: AppTypography.chipLabel.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
