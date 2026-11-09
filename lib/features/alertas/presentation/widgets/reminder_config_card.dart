import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';

/// Card de Configuração para um Lembrete de Saúde Cognitiva (`RF21`).
class ReminderConfigCard extends StatelessWidget {
  const ReminderConfigCard({
    required this.config,
    required this.onToggleAtivo,
    required this.onUpdateConfig,
    required this.onTestarAlerta,
    super.key,
  });

  final LembreteConfigEntity config;
  final ValueChanged<bool> onToggleAtivo;
  final ValueChanged<LembreteConfigEntity> onUpdateConfig;
  final VoidCallback onTestarAlerta;

  static const List<int> _intervalosSugeridos = <int>[45, 60, 90, 120, 180];

  Future<void> _selecionarHorarioFixo(BuildContext context) async {
    final TimeOfDay initial = config.horarioFixo != null
        ? TimeOfDay(
            hour: int.tryParse(config.horarioFixo!.split(':')[0]) ?? 22,
            minute: int.tryParse(config.horarioFixo!.split(':')[1]) ?? 0,
          )
        : const TimeOfDay(hour: 22, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final String hh = picked.hour.toString().padLeft(2, '0');
      final String mm = picked.minute.toString().padLeft(2, '0');
      onUpdateConfig(config.copyWith(horarioFixo: '$hh:$mm'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIntervalBased = config.intervaloMinutos != null;

    return AppCard(
      key: Key('reminder_card_${config.tipo.name}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header: Ícone + Título + Switch
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.ativo
                      ? const Color(0xFFEEF2FF)
                      : AppColors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icone,
                  color: config.ativo
                      ? AppColors.primaryBrand
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      config.titulo,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: config.ativo
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.descricao,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: Key('switch_reminder_${config.tipo.name}'),
                value: config.ativo,
                activeThumbColor: AppColors.primaryBrand,
                onChanged: onToggleAtivo,
              ),
            ],
          ),

          if (config.ativo) ...<Widget>[
            const Divider(height: AppSpacing.md),

            // Parâmetros de Intervalo ou Horário
            if (isIntervalBased) ...<Widget>[
              Text(
                'Intervalo de Repetição:',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Wrap(
                spacing: AppSpacing.xs,
                children: _intervalosSugeridos.map((minutos) {
                  final bool isSelected = config.intervaloMinutos == minutos;
                  return ChoiceChip(
                    key: Key('chip_intervalo_${config.tipo.name}_$minutos'),
                    label: Text('$minutos min'),
                    selected: isSelected,
                    selectedColor: const Color(0xFFEEF2FF),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryBrand
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      onUpdateConfig(
                        config.copyWith(intervaloMinutos: minutos),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Janela ativa: das ${config.janelaInicio} às ${config.janelaFim}',
                style: AppTypography.chipLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...<Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Horário programado:',
                      style: AppTypography.labelLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  OutlinedButton.icon(
                    key: Key('btn_horario_${config.tipo.name}'),
                    icon: const Icon(Icons.access_time_rounded, size: 16),
                    label: Text(config.horarioFixo ?? '22:00'),
                    onPressed: () => _selecionarHorarioFixo(context),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // Botão "Testar alerta agora"
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: Key('test_reminder_${config.tipo.name}'),
                onPressed: onTestarAlerta,
                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Testar alerta agora'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBrand,
                  side: const BorderSide(color: AppColors.primaryBrand),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.chipRadius,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
