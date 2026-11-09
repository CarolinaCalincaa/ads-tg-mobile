import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/pomodoro_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/animated_circle_checkbox.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/inline_checklist_accordion.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/pomodoro_player_sheet.dart';

class TimelineItemCard extends ConsumerWidget {
  const TimelineItemCard({
    required this.item,
    super.key,
    this.onEdit,
    this.onReschedule,
    this.onDelete,
  });

  final TimelineItemEntity item;
  final VoidCallback? onEdit;
  final VoidCallback? onReschedule;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color pilarColor = AppColors.fromHex(item.pilar.corHex);
    final Set<String> expandedIds =
        ref.watch(painelDiaNotifierProvider).expandedChecklistIds;

    return AppCard(
      key: Key('timeline_item_card_${item.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header: PilarChip + PriorityBadge + Menu
          Row(
            children: <Widget>[
              PilarChip(
                nome: item.pilar.nome,
                corHex: item.pilar.corHex,
                corFundoHex: item.pilar.corFundoHex,
                icone: item.pilar.icone,
              ),
              const SizedBox(width: AppSpacing.xs),
              PriorityBadge(priority: item.prioridade),
              const Spacer(),
              if (item.ehHabito)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppSpacing.chipRadius,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.repeat_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hábito',
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!item.ehHabito && !item.concluido) ...<Widget>[
                IconButton(
                  key: Key('iniciar_pomodoro_${item.id}'),
                  icon: const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 22,
                    color: AppColors.primaryBrand,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Iniciar Pomodoro',
                  onPressed: () {
                    ref.read(pomodoroNotifierProvider.notifier).start(item);
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surfaceCard,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => const PomodoroPlayerSheet(),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (!item.ehHabito)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'reschedule') onReschedule?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: AppSpacing.xs),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'reschedule',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.calendar_today_outlined, size: 18),
                          SizedBox(width: AppSpacing.xs),
                          Text('Remanejar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.fatigueCritical),
                          SizedBox(width: AppSpacing.xs),
                          Text('Excluir',
                              style: TextStyle(color: AppColors.fatigueCritical)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Body: Checkbox + Título + Descrição
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedCircleCheckbox(
                isChecked: item.concluido,
                color: pilarColor,
                onChanged: (_) {
                  ref
                      .read(painelDiaNotifierProvider.notifier)
                      .toggleItemCompletion(item);
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.nome,
                      style: AppTypography.cardTitle.copyWith(
                        decoration: item.concluido
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.concluido
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (item.descricao != null &&
                        item.descricao!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        item.descricao!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Footer: Duração + Projeto + Checklists + Pomodoros
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              // Duração
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppSpacing.chipRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.duracaoEstimadaMinutos} min',
                      style: AppTypography.chipLabel.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Projeto
              if (item.projeto != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.folder_outlined,
                        size: 13,
                        color: AppColors.primaryBrand,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.projeto!.nome,
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Checklists (com botão expansível inline - RF20)
              ...item.checklists.map((chk) {
                final bool isExpanded = expandedIds.contains(chk.id);
                return InkWell(
                  onTap: () {
                    ref
                        .read(painelDiaNotifierProvider.notifier)
                        .toggleChecklistAccordion(chk.id);
                  },
                  borderRadius: AppSpacing.chipRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? pilarColor.withValues(alpha: 0.15)
                          : AppColors.surfaceSubtle,
                      borderRadius: AppSpacing.chipRadius,
                      border: Border.all(
                        color: isExpanded ? pilarColor : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.checklist_rounded,
                          size: 13,
                          color: isExpanded
                              ? pilarColor
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '☑️ ${chk.progressoFormatado}',
                          style: AppTypography.chipLabel.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isExpanded
                                ? pilarColor
                                : AppColors.textPrimary,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Pomodoros
              if (item.pomodorosConcluidos > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppSpacing.chipRadius,
                  ),
                  child: Text(
                    '🍅 ${item.pomodorosConcluidos}',
                    style: AppTypography.chipLabel.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),

          // Acordeão de Checklists Expandidas
          ...item.checklists.where((c) => expandedIds.contains(c.id)).map(
                (c) => InlineChecklistAccordion(
                  checklist: c,
                  accentColor: pilarColor,
                ),
              ),
        ],
      ),
    );
  }
}
