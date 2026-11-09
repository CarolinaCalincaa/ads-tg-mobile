import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';

/// Banner de Alerta Crítico de Fadiga Mental (RN02 / RF17).
///
/// Reproduz fielmente o Mockup 01 do TCC quando a ocupação do dia ultrapassa 80% das horas úteis.
class FadigaAlertBanner extends StatelessWidget {
  const FadigaAlertBanner({
    required this.capacidade,
    super.key,
    this.onRemanejar,
  });

  final CapacidadeDiaEntity capacidade;
  final VoidCallback? onRemanejar;

  @override
  Widget build(BuildContext context) {
    final int pct = capacidade.percentualOcupacao;
    final double progress = (pct / 100.0).clamp(0.0, 1.0);

    return Container(
      key: const Key('fadiga_alert_banner'),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.fatigueBg, // #FEF2F2
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.fatigueBorder, // #FECACA
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Linha superior: Ícone ⚠️ + Título + Badge %
          Row(
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.fatigueCritical, // #DC2626
                size: 22,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Risco de Fadiga Mental',
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.fatigueCritical,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.priorityHighBg,
                  borderRadius: AppSpacing.chipRadius,
                  border: Border.all(color: AppColors.fatigueBorder),
                ),
                child: Text(
                  '$pct%',
                  key: const Key('fadiga_badge_percentual'),
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.fatigueCritical,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Barra de progresso vermelha
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFFEE2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.fatigueCritical, // #DC2626
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Subtítulo canônico
          Text(
            '$pct% das horas úteis comprometidas. Novos agendamentos bloqueados.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.fatigueCritical,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Botão de ação rápida: Remanejar atividades ->
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              key: const Key('remanejar_atividades_btn'),
              onTap: onRemanejar,
              borderRadius: AppSpacing.chipRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Remanejar atividades ->',
                      style: AppTypography.chipLabel.copyWith(
                        color: AppColors.fatigueCritical,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
