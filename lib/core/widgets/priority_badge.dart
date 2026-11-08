import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Níveis canônicos de prioridade de uma tarefa (`NivelPrioridade` no Prisma).
enum TaskPriority {
  prioridade(
    apiCode: 'PRIORIDADE',
    label: 'Prioridade',
    backgroundColor: AppColors.priorityHighBg,
    foregroundColor: AppColors.priorityHighFg,
  ),
  rapido(
    apiCode: 'RAPIDO',
    label: 'Rápido',
    backgroundColor: AppColors.priorityQuickBg,
    foregroundColor: AppColors.priorityQuickFg,
  ),
  postergavel(
    apiCode: 'POSTERGAVEL',
    label: 'Postergável',
    backgroundColor: AppColors.priorityDeferBg,
    foregroundColor: AppColors.priorityDeferFg,
  );

  const TaskPriority({
    required this.apiCode,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String apiCode;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  static TaskPriority fromApiCode(String? code) {
    return switch (code?.toUpperCase()) {
      'PRIORIDADE' => TaskPriority.prioridade,
      'RAPIDO' => TaskPriority.rapido,
      'POSTERGAVEL' => TaskPriority.postergavel,
      _ => TaskPriority.prioridade,
    };
  }
}

/// Tag semântica de prioridade (`Prioridade`, `Rápido`, `Postergável`) com contraste WCAG AA (`RNF04`).
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    required this.priority,
    super.key,
  });

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: AppSpacing.chipRadius,
      ),
      child: Text(
        priority.label,
        style: AppTypography.chipLabel.copyWith(
          color: priority.foregroundColor,
        ),
      ),
    );
  }
}
