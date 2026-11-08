import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';

/// Card interativo de configuração das Horas de Sono Diárias (`RF05` e `RN02` — `E02-T05`).
///
/// Permite selecionar de `4h` a `12h` de sono diário e exibe em tempo real:
/// `"Capacidade útil diária: {24 - sono}h ({minutos} min) • Limite saudável (80%): {limite} min"`.
class SleepHoursSelectorCard extends StatefulWidget {
  const SleepHoursSelectorCard({
    required this.initialSleepHours,
    required this.onSave,
    super.key,
    this.isSaving = false,
  });

  final int initialSleepHours;
  final ValueChanged<int> onSave;
  final bool isSaving;

  @override
  State<SleepHoursSelectorCard> createState() => _SleepHoursSelectorCardState();
}

class _SleepHoursSelectorCardState extends State<SleepHoursSelectorCard> {
  late int _selectedHours;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.initialSleepHours.clamp(4, 12);
  }

  @override
  void didUpdateWidget(covariant SleepHoursSelectorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSleepHours != widget.initialSleepHours) {
      _selectedHours = widget.initialSleepHours.clamp(4, 12);
    }
  }

  void _updateHours(int newHours) {
    final int clamped = newHours.clamp(4, 12);
    if (clamped != _selectedHours) {
      setState(() {
        _selectedHours = clamped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int horasUteis = 24 - _selectedHours;
    final int minutosUteis = horasUteis * 60;
    final int limiteSaudavel = (minutosUteis * 0.8).round();
    final bool hasChanged = _selectedHours != widget.initialSleepHours;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.pilarSonoBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bedtime_rounded,
                  color: AppColors.pilarSono,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Horas Diárias de Sono (RF05 / RN02)',
                      style: AppTypography.cardTitle,
                    ),
                    Text(
                      'Define seu tempo útil acordado e o limite de fadiga mental.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                key: const Key('sleep_hours_decrement_button'),
                tooltip: 'Diminuir 1 hora',
                onPressed: _selectedHours > 4 && !widget.isSaving
                    ? () => _updateHours(_selectedHours - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.pilarSono,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.pilarSonoBg,
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    '${_selectedHours}h de sono / noite',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.tabularNumber.copyWith(
                      fontSize: 16,
                      color: AppColors.pilarSono,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                key: const Key('sleep_hours_increment_button'),
                tooltip: 'Aumentar 1 hora',
                onPressed: _selectedHours < 12 && !widget.isSaving
                    ? () => _updateHours(_selectedHours + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.pilarSono,
              ),
            ],
          ),
          Slider(
            key: const Key('config_sleep_slider'),
            value: _selectedHours.toDouble(),
            min: 4,
            max: 12,
            divisions: 8,
            label: '${_selectedHours}h',
            activeColor: AppColors.pilarSono,
            onChanged: widget.isSaving
                ? null
                : (double value) => _updateHours(value.round()),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppSpacing.inputRadius,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              key: const Key('sleep_capacity_formula_text'),
              'Capacidade útil diária: ${horasUteis}h ($minutosUteis min) • Limite saudável (80%): $limiteSaudavel min',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryGradientButton(
            key: const Key('save_sleep_hours_button'),
            label: 'Salvar horas de sono',
            icon: Icons.check_rounded,
            isLoading: widget.isSaving,
            isDisabled: !hasChanged,
            onPressed: () => widget.onSave(_selectedHours),
          ),
        ],
      ),
    );
  }
}
