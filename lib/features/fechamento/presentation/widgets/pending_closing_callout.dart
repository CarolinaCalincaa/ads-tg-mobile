import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

class PendingClosingCallout extends StatelessWidget {
  const PendingClosingCallout({
    super.key,
    required this.onTap,
    this.titulo = 'Momento do Fechamento Reflexivo',
    this.subtitulo =
        'Revise seus hábitos, celebre vitórias e planeje o próximo ciclo com calma.',
  });

  final VoidCallback onTap;
  final String titulo;
  final String subtitulo;

  /// Retorna true se hoje for Domingo (7) ou os últimos 2 dias do mês civil.
  static bool shouldShowForDate(DateTime data) {
    if (data.weekday == DateTime.sunday) {
      return true;
    }
    // Verifica se faltam 2 dias ou menos para o fim do mês
    final DateTime amanha = data.add(const Duration(days: 1));
    final DateTime depoisDeAmanha = data.add(const Duration(days: 2));
    if (amanha.month != data.month || depoisDeAmanha.month != data.month) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primaryBrand.withValues(alpha: 0.12),
            AppColors.accentViolet.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBrand.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: AppColors.primaryBrandDark,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titulo,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ElevatedButton(
            key: const Key('btn_iniciar_fechamento_callout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: onTap,
            child: const Text('Iniciar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
