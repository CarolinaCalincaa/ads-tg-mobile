import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/cycle_metric_summary_row.dart';

class FechamentoDetailSheet extends StatelessWidget {
  const FechamentoDetailSheet({
    super.key,
    required this.fechamento,
  });

  final FechamentoEntity fechamento;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fechamento.tipoCiclo == 'SEMANAL'
                      ? 'Fechamento Semanal'
                      : 'Fechamento Mensal',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.primaryBrandDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.capacityHealthy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${fechamento.metricas.consistenciaPercentual}% consistência',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.capacityHealthy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fechamento.rotuloPeriodo,
            style: AppTypography.displayTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CycleMetricSummaryRow(metricas: fechamento.metricas),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              children: <Widget>[
                _ReflectionAnswerBlock(
                  emoji: '⭐',
                  title: 'Ação que funcionou bem',
                  content: fechamento.acaoFuncionouBem,
                ),
                _ReflectionAnswerBlock(
                  emoji: '📈',
                  title: 'O que farei diferente',
                  content: fechamento.oqueFazerDiferente,
                ),
                _ReflectionAnswerBlock(
                  emoji: '🏅',
                  title: 'Vitória a reconhecer',
                  content: fechamento.vitoriaReconhecer,
                ),
                _ReflectionAnswerBlock(
                  emoji: '🎯',
                  title: 'Fracasso a aceitar',
                  content: fechamento.fracassoAceitar,
                ),
                if (fechamento.insightIa != null &&
                    fechamento.insightIa!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentViolet.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentViolet.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.accentViolet,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Insight da IA',
                              style: AppTypography.chipLabel.copyWith(
                                color: AppColors.accentViolet,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          fechamento.insightIa!,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionAnswerBlock extends StatelessWidget {
  const _ReflectionAnswerBlock({
    required this.emoji,
    required this.title,
    required this.content,
  });

  final String emoji;
  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = content == null || content!.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isEmpty ? 'Não informado neste ciclo.' : content!,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
