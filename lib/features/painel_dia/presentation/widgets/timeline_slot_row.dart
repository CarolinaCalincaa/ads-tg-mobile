import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/timeline_item_card.dart';

class TimelineSlotRow extends StatelessWidget {
  const TimelineSlotRow({
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
  Widget build(BuildContext context) {
    final String horarioExibicao = item.horario ?? '--:--';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Slot de Horário à esquerda
          SizedBox(
            width: 48,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                horarioExibicao,
                style: AppTypography.chipLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  color: item.horario != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Card da Atividade à direita
          Expanded(
            child: TimelineItemCard(
              item: item,
              onEdit: onEdit,
              onReschedule: onReschedule,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
