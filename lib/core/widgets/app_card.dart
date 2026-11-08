import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';

/// Card compartilhado do Design System "Calma Cognitiva" (`Tech Doc 05 — Seção 1.2`).
///
/// Possui `borderRadius: 20px`, borda sutil `#E2E8F0` de `1px` e sombra difusa suave.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.backgroundColor = AppColors.surfaceCard,
    this.borderColor = AppColors.borderSubtle,
    this.borderWidth = 1.0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding,
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              borderRadius: AppSpacing.cardRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppSpacing.cardRadius,
                child: content,
              ),
            )
          : content,
    );
  }
}
