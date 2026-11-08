import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';

/// Checkbox circular com animação fluida e área de toque de 48dp (`RNF04`).
class AnimatedCircleCheckbox extends StatelessWidget {
  const AnimatedCircleCheckbox({
    required this.isChecked,
    required this.onChanged,
    required this.color,
    super.key,
    this.size = 24.0,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isChecked,
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(AppSpacing.minTapTarget / 2),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.minTapTarget,
            minHeight: AppSpacing.minTapTarget,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuad,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? color : Colors.transparent,
                border: Border.all(
                  color: isChecked ? color : color.withValues(alpha: 0.8),
                  width: 2.0,
                ),
                boxShadow: isChecked
                    ? <BoxShadow>[
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isChecked ? 1.0 : 0.0,
                child: const Icon(
                  Icons.check_rounded,
                  size: 16.0,
                  color: AppColors.surfaceCard,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
