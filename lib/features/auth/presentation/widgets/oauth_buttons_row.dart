import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Linha de botões de autenticação social OAuth 2.0 (`RF03`, `Tech Doc 05 — Seção 3.1`).
///
/// Suporta **Continuar com Google** e **Continuar com Apple** com área mínima de toque de `48dp` (`RNF04`).
class OAuthButtonsRow extends StatelessWidget {
  const OAuthButtonsRow({
    required this.onGooglePressed,
    required this.onApplePressed,
    super.key,
    this.isLoading = false,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SocialButton(
          key: const Key('oauth_google_button'),
          label: 'Continuar com Google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: AppColors.primaryBrand,
          onPressed: isLoading ? null : onGooglePressed,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialButton(
          key: const Key('oauth_apple_button'),
          label: 'Continuar com Apple',
          icon: Icons.apple_rounded,
          iconColor: AppColors.textPrimary,
          onPressed: isLoading ? null : onApplePressed,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.minTapTarget,
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.inputRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        icon: Icon(icon, size: 22, color: iconColor),
        label: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
