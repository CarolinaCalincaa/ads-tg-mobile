import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';

class FechamentoHistoryCard extends StatelessWidget {
  const FechamentoHistoryCard({
    super.key,
    required this.fechamento,
    required this.onTap,
  });

  final FechamentoEntity fechamento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSemanal = fechamento.tipoCiclo == 'SEMANAL';
    final String resumoRespostas = <String?>[
      fechamento.acaoFuncionouBem,
      fechamento.oqueFazerDiferente,
      fechamento.vitoriaReconhecer,
    ].firstWhere(
      (String? s) => s != null && s.trim().isNotEmpty,
      orElse: () => 'Sem anotações detalhadas',
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSemanal
                          ? AppColors.primaryBrand.withValues(alpha: 0.1)
                          : AppColors.accentViolet.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSemanal ? 'SEMANAL' : 'MENSAL',
                      style: AppTypography.chipLabel.copyWith(
                        color: isSemanal
                            ? AppColors.primaryBrandDark
                            : AppColors.accentViolet,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      fechamento.rotuloPeriodo,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.capacityHealthy.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${fechamento.metricas.consistenciaPercentual}%',
                      style: AppTypography.chipLabel.copyWith(
                        color: AppColors.capacityHealthy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: <Widget>[
                  Text(
                    '${fechamento.metricas.habitosConcluidos}/${fechamento.metricas.habitosEsperados} hábitos',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(' • '),
                  Text(
                    '${fechamento.metricas.diasAtivos} dias ativos',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(' • '),
                  Text(
                    '${fechamento.metricas.sequenciaAtualDias}d 🔥',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                resumoRespostas,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
