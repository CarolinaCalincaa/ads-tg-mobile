import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';

/// Barra compacta de capacidade diária exibida quando a ocupação está em nível seguro ou de atenção (<= 80%).
///
/// Implementa `RF16` e `RNF04`, fornecendo feedback imediato de carga horária sem gerar alarme falso.
class CompactCapacityBar extends StatelessWidget {
  const CompactCapacityBar({
    required this.capacidade,
    super.key,
    this.onTap,
  });

  final CapacidadeDiaEntity capacidade;
  final VoidCallback? onTap;

  String _formatMinutos(int totalMinutos) {
    final int horas = totalMinutos ~/ 60;
    final int minutos = totalMinutos % 60;
    if (minutos == 0) return '${horas}h';
    if (horas == 0) return '${minutos}m';
    return '${horas}h ${minutos}m';
  }

  @override
  Widget build(BuildContext context) {
    final int pct = capacidade.percentualOcupacao;
    final bool isAviso = pct > 60;
    final Color statusColor =
        isAviso ? AppColors.capacityWarning : AppColors.capacityHealthy;
    final double progress = capacidade.minutosUteis > 0
        ? (capacidade.minutosComprometidos / capacidade.minutosUteis)
            .clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.cardRadius,
      child: Container(
        key: const Key('compact_capacity_bar'),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isAviso
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Capacidade do Dia',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${_formatMinutos(capacidade.minutosComprometidos)} / ${_formatMinutos(capacidade.minutosUteis)}',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    '$pct%',
                    key: const Key('compact_capacity_percent'),
                    style: AppTypography.chipLabel.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
