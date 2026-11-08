import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Pílula visual que representa um dos 7 Pilares de Vida (`Tech Doc 02 — Seção 2` e `Tech Doc 05`).
///
/// Renderiza o ícone + nome do pilar aplicando `corFundoHex` e `corHex`.
class PilarChip extends StatelessWidget {
  const PilarChip({
    required this.nome,
    required this.corHex,
    required this.corFundoHex,
    super.key,
    this.icone,
    this.iconData,
    this.isSelected = false,
    this.onTap,
  });

  final String nome;
  final String corHex;
  final String corFundoHex;
  final String? icone;
  final IconData? iconData;
  final bool isSelected;
  final VoidCallback? onTap;

  /// Mapeia o identificador textual do banco (`pilar_vida.icone`) para um [IconData] Material.
  static IconData resolveIcon(String? iconName) {
    return switch (iconName) {
      'heart_pulse' => Icons.favorite_border_rounded,
      'activity' => Icons.directions_run_rounded,
      'moon' => Icons.nightlight_outlined,
      'brain' => Icons.psychology_outlined,
      'book_open' => Icons.menu_book_rounded,
      'wallet' => Icons.account_balance_wallet_outlined,
      'briefcase' => Icons.work_outline_rounded,
      _ => Icons.label_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = AppColors.fromHex(corHex);
    final Color backgroundColor = AppColors.fromHex(
      corFundoHex,
      fallback: AppColors.surfaceSubtle,
    );
    final IconData resolvedIcon = iconData ?? resolveIcon(icone);

    final Widget chipBody = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.chipRadius,
        border: Border.all(
          color: isSelected
              ? foregroundColor
              : foregroundColor.withValues(alpha: 0.25),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            resolvedIcon,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            nome,
            style: AppTypography.chipLabel.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chipBody;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.chipRadius,
        child: chipBody,
      ),
    );
  }
}
