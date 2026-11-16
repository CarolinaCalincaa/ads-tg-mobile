import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/animated_circle_checkbox.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';

/// Card de Tarefa/Compromisso na visão do Centro de Controle (Rotina).
class RotinaTaskCard extends StatelessWidget {
  const RotinaTaskCard({
    required this.tarefa,
    required this.onToggleStatus,
    this.onEdit,
    this.onReschedule,
    this.onDelete,
    super.key,
  });

  final RotinaTarefaEntity tarefa;
  final VoidCallback onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onReschedule;
  final VoidCallback? onDelete;

  String _formatDateBadge(String rawDate) {
    if (rawDate.isEmpty) return 'Sem data';
    final List<String> parts = rawDate.split('-');
    if (parts.length != 3) return rawDate;
    final int? y = int.tryParse(parts[0]);
    final int? m = int.tryParse(parts[1]);
    final int? d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return rawDate;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(y, m, d);
    final int diff = target.difference(today).inDays;

    final String ddMm =
        '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}';

    if (diff == 0) return 'Hoje ($ddMm)';
    if (diff == 1) return 'Amanhã ($ddMm)';
    if (diff == -1) return 'Ontem ($ddMm)';
    return ddMm;
  }

  bool _isOverdue(String rawDate, bool concluido) {
    if (concluido || rawDate.isEmpty) return false;
    final List<String> parts = rawDate.split('-');
    if (parts.length != 3) return false;
    final int? y = int.tryParse(parts[0]);
    final int? m = int.tryParse(parts[1]);
    final int? d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return false;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(y, m, d);
    return target.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final bool atrasada = _isOverdue(tarefa.dataAgendamento, tarefa.concluido);

    return AppCard(
      key: Key('rotina_task_card_${tarefa.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Linha 1: Pilar + Prioridade + Tipo + Menu
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    PilarChip(
                      nome: tarefa.pilar.nome,
                      corHex: tarefa.pilar.corHex,
                      corFundoHex: tarefa.pilar.corFundoHex,
                      icone: tarefa.pilar.icone,
                    ),
                    PriorityBadge(priority: tarefa.prioridade),
                    if (tarefa.ehCompromisso)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: AppSpacing.chipRadius,
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          'Compromisso',
                          style: AppTypography.chipLabel.copyWith(
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                key: Key('menu_rotina_task_${tarefa.id}'),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onSelected: (String action) {
                  if (action == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (action == 'reschedule' && onReschedule != null) {
                    onReschedule!();
                  } else if (action == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reschedule',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Reagendar data'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.fatigueCritical,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Excluir',
                          style: TextStyle(color: AppColors.fatigueCritical),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Linha 2: Checkbox + Título + Descrição
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AnimatedCircleCheckbox(
                  key: Key('rotina_task_checkbox_${tarefa.id}'),
                  isChecked: tarefa.concluido,
                  color: AppColors.fromHex(tarefa.pilar.corHex),
                  onChanged: (_) => onToggleStatus(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tarefa.nome,
                      style: AppTypography.cardTitle.copyWith(
                        decoration: tarefa.concluido
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: tarefa.concluido
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (tarefa.descricao != null &&
                        tarefa.descricao!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        tarefa.descricao!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Linha 3: Metadados (Data agendada, Horário, Duração, Projeto, Checklist)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              // Badge de Data
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: atrasada
                      ? const Color(0xFFFEF2F2)
                      : AppColors.surfaceSubtle,
                  borderRadius: AppSpacing.chipRadius,
                  border: Border.all(
                    color: atrasada
                        ? const Color(0xFFFECACA)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: atrasada
                          ? AppColors.fatigueCritical
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateBadge(tarefa.dataAgendamento),
                      style: AppTypography.chipLabel.copyWith(
                        color: atrasada
                            ? AppColors.fatigueCritical
                            : AppColors.textPrimary,
                        fontWeight:
                            atrasada ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Horário
              if (tarefa.horarioInicio != null &&
                  tarefa.horarioInicio!.isNotEmpty)
                _MetaBadge(
                  icon: Icons.schedule_rounded,
                  label: tarefa.horarioInicio!,
                ),

              // Duração
              _MetaBadge(
                icon: Icons.timer_outlined,
                label: '${tarefa.duracaoEstimadaMinutos} min',
              ),

              // Projeto
              if (tarefa.projeto != null)
                _MetaBadge(
                  icon: Icons.folder_outlined,
                  label: tarefa.projeto!.nome,
                  color: AppColors.primaryBrand,
                ),

              // Progresso de Checklist
              if (tarefa.totalChecklistItens > 0)
                _MetaBadge(
                  icon: Icons.checklist_rounded,
                  label:
                      '${tarefa.concluidosChecklistItens}/${tarefa.totalChecklistItens}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de Hábito Recorrente na visão do Centro de Controle (Rotina).
class RotinaHabitCard extends StatelessWidget {
  const RotinaHabitCard({
    required this.habito,
    required this.onToggleAtivo,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final RotinaHabitoEntity habito;
  final ValueChanged<bool> onToggleAtivo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const List<Map<String, dynamic>> _diasLabels = <Map<String, dynamic>>[
    <String, dynamic>{'dia': 1, 'sigla': 'S'},
    <String, dynamic>{'dia': 2, 'sigla': 'T'},
    <String, dynamic>{'dia': 3, 'sigla': 'Q'},
    <String, dynamic>{'dia': 4, 'sigla': 'Q'},
    <String, dynamic>{'dia': 5, 'sigla': 'S'},
    <String, dynamic>{'dia': 6, 'sigla': 'S'},
    <String, dynamic>{'dia': 7, 'sigla': 'D'},
  ];

  @override
  Widget build(BuildContext context) {
    final Color pilarColor = AppColors.fromHex(habito.pilar.corHex);

    return AppCard(
      key: Key('rotina_habit_card_${habito.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Linha 1: Pilar + Badge Streak + Switch Ativo + Menu
          Row(
            children: <Widget>[
              PilarChip(
                nome: habito.pilar.nome,
                corHex: habito.pilar.corHex,
                corFundoHex: habito.pilar.corFundoHex,
                icone: habito.pilar.icone,
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: AppSpacing.chipRadius,
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${habito.streakAtual}d',
                      style: AppTypography.chipLabel.copyWith(
                        color: const Color(0xFFC2410C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                key: Key('rotina_habit_switch_${habito.id}'),
                value: habito.statusAtivo,
                activeTrackColor: AppColors.primaryBrand,
                onChanged: onToggleAtivo,
              ),
              PopupMenuButton<String>(
                key: Key('menu_rotina_habit_${habito.id}'),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onSelected: (String action) {
                  if (action == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (action == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Editar Hábito'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.fatigueCritical,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Excluir',
                          style: TextStyle(color: AppColors.fatigueCritical),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Linha 2: Nome e Descrição
          Text(
            habito.nome,
            style: AppTypography.cardTitle.copyWith(
              color: habito.statusAtivo
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          if (habito.descricao != null &&
              habito.descricao!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              habito.descricao!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),

          // Linha 3: Bolinhas dos dias da semana (S T Q Q S S D) + Horário e Duração
          Row(
            children: <Widget>[
              // Bolinhas dos dias
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _diasLabels.map((info) {
                  final int dia = info['dia'] as int;
                  final String sigla = info['sigla'] as String;
                  final bool ativoDia = habito.diasSemana.contains(dia);

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ativoDia
                            ? pilarColor.withValues(alpha: 0.16)
                            : AppColors.surfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ativoDia ? pilarColor : AppColors.borderSubtle,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sigla,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ativoDia ? pilarColor : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              if (habito.horarioPadrao != null &&
                  habito.horarioPadrao!.isNotEmpty) ...<Widget>[
                _MetaBadge(
                  icon: Icons.schedule_rounded,
                  label: habito.horarioPadrao!,
                ),
                const SizedBox(width: 6),
              ],
              _MetaBadge(
                icon: Icons.timer_outlined,
                label: '${habito.duracaoEstimadaMinutos} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppSpacing.chipRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.chipLabel.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
