import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Avaliação individual dos 5 critérios obrigatórios de força de senha (`RF02` e `RNF05`).
class PasswordStrengthEvaluation {
  const PasswordStrengthEvaluation({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  int get metCriteriaCount => <bool>[
    hasMinLength,
    hasUppercase,
    hasLowercase,
    hasDigit,
    hasSpecialChar,
  ].where((bool met) => met).length;

  bool get isStrong => metCriteriaCount == 5;
}

/// Validador determinístico de força de senha (`RF02`).
abstract final class PasswordStrengthValidator {
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'\d');
  static final RegExp _specialCharRegex = RegExp(r'[^A-Za-z0-9]');

  static PasswordStrengthEvaluation evaluate(String password) {
    return PasswordStrengthEvaluation(
      hasMinLength: password.length >= 8,
      hasUppercase: _uppercaseRegex.hasMatch(password),
      hasLowercase: _lowercaseRegex.hasMatch(password),
      hasDigit: _digitRegex.hasMatch(password),
      hasSpecialChar: _specialCharRegex.hasMatch(password),
    );
  }

  static bool isStrong(String password) => evaluate(password).isStrong;

  static String? validateField(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Informe uma senha.';
    }
    if (!isStrong(password)) {
      return 'A senha deve atender a todos os 5 critérios de segurança.';
    }
    return null;
  }
}

/// Checklist visual em tempo real dos requisitos de segurança da senha (`RF02`, `E02-T04`).
class PasswordStrengthChecklist extends StatelessWidget {
  const PasswordStrengthChecklist({
    required this.password,
    super.key,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final PasswordStrengthEvaluation evaluation =
        PasswordStrengthValidator.evaluate(password);
    final double progress = evaluation.metCriteriaCount / 5.0;

    final Color progressColor = switch (evaluation.metCriteriaCount) {
      0 || 1 || 2 => AppColors.fatigueCritical,
      3 || 4 => AppColors.capacityWarning,
      _ => AppColors.capacityHealthy,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppSpacing.inputRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Segurança da senha',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${evaluation.metCriteriaCount}/5 critérios',
                style: AppTypography.tabularNumber.copyWith(
                  fontSize: 12,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppSpacing.chipRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _CriterionRow(
            label: 'Mínimo de 8 caracteres',
            isMet: evaluation.hasMinLength,
          ),
          _CriterionRow(
            label: 'Ao menos 1 letra maiúscula (A–Z)',
            isMet: evaluation.hasUppercase,
          ),
          _CriterionRow(
            label: 'Ao menos 1 letra minúscula (a–z)',
            isMet: evaluation.hasLowercase,
          ),
          _CriterionRow(
            label: 'Ao menos 1 número (0–9)',
            isMet: evaluation.hasDigit,
          ),
          _CriterionRow(
            label: 'Ao menos 1 caractere especial (!@#\$%&*)',
            isMet: evaluation.hasSpecialChar,
          ),
        ],
      ),
    );
  }
}

class _CriterionRow extends StatelessWidget {
  const _CriterionRow({
    required this.label,
    required this.isMet,
  });

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: <Widget>[
          Icon(
            isMet
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? AppColors.capacityHealthy : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
