import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';

class DateNavigatorBar extends ConsumerWidget {
  const DateNavigatorBar({super.key});

  static const List<String> _meses = <String>[
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final bool isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final String mesNome = _meses[date.month - 1];

    if (isToday) {
      return 'Hoje • ${date.day} de $mesNome';
    }
    return '${date.day} de $mesNome de ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedDate = ref.watch(selectedDateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            key: const Key('prev_day_button'),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Dia anterior',
            onPressed: () {
              ref.read(selectedDateProvider.notifier).previousDay();
            },
          ),
          Expanded(
            child: InkWell(
              key: const Key('open_date_picker_button'),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  ref.read(selectedDateProvider.notifier).setDate(picked);
                }
              },
              borderRadius: AppSpacing.chipRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primaryBrand,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        _formatDate(selectedDate),
                        style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('next_day_button'),
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Próximo dia',
            onPressed: () {
              ref.read(selectedDateProvider.notifier).nextDay();
            },
          ),
        ],
      ),
    );
  }
}
