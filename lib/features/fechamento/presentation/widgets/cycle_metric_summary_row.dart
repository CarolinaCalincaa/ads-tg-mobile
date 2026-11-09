import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';

class CycleMetricSummaryRow extends StatelessWidget {
  const CycleMetricSummaryRow({
    super.key,
    required this.metricas,
  });

  final FechamentoMetricas metricas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricCard(
            key: const Key('metric_card_habitos'),
            value: '${metricas.habitosConcluidos}/${metricas.habitosEsperados}',
            label: 'Hábitos concluídos',
            icon: Icons.check_circle_outline,
            accentColor: AppColors.capacityHealthy,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            key: const Key('metric_card_dias_ativos'),
            value: '${metricas.diasAtivos}/${metricas.totalDiasCiclo}',
            label: 'Dias ativos',
            icon: Icons.calendar_today_outlined,
            accentColor: AppColors.primaryBrand,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            key: const Key('metric_card_streak'),
            value: '${metricas.sequenciaAtualDias} dias 🔥',
            label: 'Sequência atual',
            icon: Icons.local_fire_department_outlined,
            accentColor: AppColors.pilarMovimento,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: accentColor),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
