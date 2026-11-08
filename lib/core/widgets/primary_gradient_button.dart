import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Botão de ação principal com gradiente oficial (`#6366F1` -> `#7C3AED`).
///
/// Suporta estados `isLoading` e `isDisabled` mantendo área mínima de toque de `48dp` (`RNF04`).
class PrimaryGradientButton extends StatelessWidget {
  const PrimaryGradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  bool get _isInteractive => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        widthFactor: fullWidth ? null : 1.0,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.surfaceCard,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(
                      icon,
                      size: 18,
                      color: _isInteractive
                          ? AppColors.surfaceCard
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: _isInteractive
                            ? AppColors.surfaceCard
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: AppSpacing.minTapTarget,
        minWidth: fullWidth ? double.infinity : 0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isInteractive ? AppColors.primaryGradient : null,
          color: _isInteractive ? null : AppColors.borderSubtle,
          borderRadius: AppSpacing.inputRadius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSpacing.inputRadius,
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            borderRadius: AppSpacing.inputRadius,
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
