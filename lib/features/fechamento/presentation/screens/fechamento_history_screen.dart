import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/providers/fechamento_notifier.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/fechamento_detail_sheet.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/fechamento_history_card.dart';

class FechamentoHistoryScreen extends ConsumerStatefulWidget {
  const FechamentoHistoryScreen({super.key});

  @override
  ConsumerState<FechamentoHistoryScreen> createState() =>
      _FechamentoHistoryScreenState();
}

class _FechamentoHistoryScreenState
    extends ConsumerState<FechamentoHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fechamentoNotifierProvider.notifier).carregarHistorico();
    });
  }

  void _abrirDetalhes(BuildContext context, FechamentoEntity item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FechamentoDetailSheet(fechamento: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FechamentoState state = ref.watch(fechamentoNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Fechamentos'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Filtro de Ciclo: Todos | Semanais | Mensais
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    ChoiceChip(
                      key: const Key('filter_todos'),
                      label: const Text('Todos'),
                      selected: state.filtroHistorico == 'TODOS',
                      onSelected: (_) {
                        ref
                            .read(fechamentoNotifierProvider.notifier)
                            .carregarHistorico(filtro: 'TODOS');
                      },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      key: const Key('filter_semanal'),
                      label: const Text('Semanais'),
                      selected: state.filtroHistorico == 'SEMANAL',
                      onSelected: (_) {
                        ref
                            .read(fechamentoNotifierProvider.notifier)
                            .carregarHistorico(filtro: 'SEMANAL');
                      },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      key: const Key('filter_mensal'),
                      label: const Text('Mensais'),
                      selected: state.filtroHistorico == 'MENSAL',
                      onSelected: (_) {
                        ref
                            .read(fechamentoNotifierProvider.notifier)
                            .carregarHistorico(filtro: 'MENSAL');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Lista do Histórico
            Expanded(
              child: state.isLoading && state.historico.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.historico.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.history_edu_outlined,
                          title: 'Nenhum fechamento registrado',
                          description:
                              'Quando você concluir seus ritos reflexivos semanais ou mensais, eles ficarão salvos aqui para consulta retroativa.',
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(fechamentoNotifierProvider.notifier)
                                .carregarHistorico();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: state.historico.length,
                            itemBuilder: (BuildContext context, int index) {
                              final FechamentoEntity item =
                                  state.historico[index];
                              return FechamentoHistoryCard(
                                key: Key('history_card_${item.id}'),
                                fechamento: item,
                                onTap: () => _abrirDetalhes(context, item),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
