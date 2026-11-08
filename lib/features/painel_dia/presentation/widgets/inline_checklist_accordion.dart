import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';

class InlineChecklistAccordion extends ConsumerStatefulWidget {
  const InlineChecklistAccordion({
    required this.checklist,
    required this.accentColor,
    super.key,
  });

  final ChecklistEntity checklist;
  final Color accentColor;

  @override
  ConsumerState<InlineChecklistAccordion> createState() =>
      _InlineChecklistAccordionState();
}

class _InlineChecklistAccordionState
    extends ConsumerState<InlineChecklistAccordion> {
  final TextEditingController _addItemController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  Future<void> _submitNewItem() async {
    final String text = _addItemController.text.trim();
    if (text.isEmpty) return;

    final result = await ref
        .read(painelRepositoryProvider)
        .addChecklistItem(
          idChecklist: widget.checklist.id,
          descricao: text,
        );

    if (mounted) {
      result.fold(
        onFailure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.fatigueCritical,
            ),
          );
        },
        onSuccess: (_) {
          _addItemController.clear();
          setState(() {
            _isAdding = false;
          });
          final dateStr = ref.read(selectedDateStringProvider);
          ref.read(painelDiaNotifierProvider.notifier).loadDia(dateStr);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle.withValues(alpha: 0.6),
        borderRadius: AppSpacing.inputRadius,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.checklist_rounded,
                size: 16,
                color: widget.accentColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.checklist.titulo,
                  style: AppTypography.chipLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                widget.checklist.progressoFormatado,
                style: AppTypography.chipLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 12, thickness: 1, color: AppColors.borderSubtle),
          ...widget.checklist.itens.map((item) {
            return InkWell(
              key: Key('checklist_item_${item.id}'),
              onTap: () {
                ref
                    .read(painelDiaNotifierProvider.notifier)
                    .toggleChecklistItem(
                      idChecklist: widget.checklist.id,
                      itemId: item.id,
                      currentConcluido: item.concluido,
                    );
              },
              borderRadius: AppSpacing.inputRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 2.0,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      item.concluido
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: item.concluido
                          ? widget.accentColor
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        item.descricao,
                        style: AppTypography.bodyMedium.copyWith(
                          decoration: item.concluido
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.concluido
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_isAdding) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _addItemController,
                    autofocus: true,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Novo item...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    onSubmitted: (_) => _submitNewItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  color: AppColors.primaryBrand,
                  onPressed: _submitNewItem,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    setState(() {
                      _isAdding = false;
                      _addItemController.clear();
                    });
                  },
                ),
              ],
            ),
          ] else ...<Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _isAdding = true;
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 14),
                label: Text(
                  'Adicionar item',
                  style: AppTypography.chipLabel.copyWith(
                    color: AppColors.primaryBrand,
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
