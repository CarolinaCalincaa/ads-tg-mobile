import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';

class RescheduleTaskSheet extends ConsumerStatefulWidget {
  const RescheduleTaskSheet({
    required this.item,
    super.key,
  });

  final TimelineItemEntity item;

  @override
  ConsumerState<RescheduleTaskSheet> createState() =>
      _RescheduleTaskSheetState();
}

class _RescheduleTaskSheetState extends ConsumerState<RescheduleTaskSheet> {
  List<Map<String, dynamic>> _sugeridos = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSugestoes();
  }

  Future<void> _loadSugestoes() async {
    final String dataOrigem = ref.read(selectedDateStringProvider);
    final result = await ref.read(painelRepositoryProvider).getDiasLivres(
          dataOrigem: dataOrigem,
          duracaoMinutos: widget.item.duracaoEstimadaMinutos,
        );

    if (!mounted) return;
    result.fold(
      onFailure: (_) {
        setState(() => _isLoading = false);
      },
      onSuccess: (dias) {
        setState(() {
          _sugeridos = dias;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _confirmReschedule(String novaData) async {
    final bool ok = await ref
        .read(painelDiaNotifierProvider.notifier)
        .rescheduleTask(widget.item.id, novaData);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Atividade remanejada para $novaData com sucesso.'),
        ),
      );
    } else {
      final errorMsg = ref.read(painelDiaNotifierProvider).failure?.message ??
          'Não foi possível remanejar.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Remanejar Atividade (RN02)',
            style: AppTypography.displayLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            widget.item.nome,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sugestões inteligentes com espaço livre:',
            style: AppTypography.cardTitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_sugeridos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Nenhum dia sugerido automaticamente.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ..._sugeridos.map((sug) {
              final String data = sug['data'] as String;
              final int novoPerc = sug['novoPercentualEstimado'] as int? ?? 50;
              final int dist = sug['distanciaDias'] as int? ?? 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: InkWell(
                  onTap: () => _confirmReschedule(data),
                  borderRadius: AppSpacing.cardRadius,
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.event_available_rounded,
                              color: AppColors.capacityHealthy,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(data, style: AppTypography.cardTitle),
                                Text(
                                  'Em +$dist dia(s)',
                                  style: AppTypography.chipLabel.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: AppSpacing.chipRadius,
                          ),
                          child: Text(
                            'Ocupação: ~$novoPerc%',
                            style: AppTypography.chipLabel.copyWith(
                              color: AppColors.capacityHealthy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                final String formatted =
                    '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                _confirmReschedule(formatted);
              }
            },
            icon: const Icon(Icons.date_range_rounded),
            label: const Text('Escolher outra data no calendário'),
          ),
        ],
      ),
    );
  }
}
