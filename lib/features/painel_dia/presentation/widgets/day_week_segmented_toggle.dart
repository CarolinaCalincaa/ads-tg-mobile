import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';

class DayWeekSegmentedToggle extends ConsumerWidget {
  const DayWeekSegmentedToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VisaoModo currentModo =
        ref.watch(painelDiaNotifierProvider).visaoModo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppSpacing.chipRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SegmentButton(
              key: const Key('toggle_modo_dia'),
              label: 'Dia',
              icon: Icons.calendar_view_day_rounded,
              isSelected: currentModo == VisaoModo.dia,
              onTap: () {
                ref
                    .read(painelDiaNotifierProvider.notifier)
                    .setVisaoModo(VisaoModo.dia);
              },
            ),
          ),
          Expanded(
            child: _SegmentButton(
              key: const Key('toggle_modo_semana'),
              label: 'Semana',
              icon: Icons.calendar_view_week_rounded,
              isSelected: currentModo == VisaoModo.semana,
              onTap: () {
                ref
                    .read(painelDiaNotifierProvider.notifier)
                    .setVisaoModo(VisaoModo.semana);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.chipRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceCard : Colors.transparent,
          borderRadius: AppSpacing.chipRadius,
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primaryBrand
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
