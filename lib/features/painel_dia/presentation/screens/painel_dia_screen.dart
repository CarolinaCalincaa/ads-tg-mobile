import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/date_navigator_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/day_week_segmented_toggle.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/painel_header.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/reschedule_task_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/task_form_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/timeline_slot_row.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/weekly_overview_section.dart';

class PainelDiaScreen extends ConsumerWidget {
  const PainelDiaScreen({super.key});

  void _abrirFormNovaTarefa(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TaskFormSheet(),
    );
  }

  void _abrirFormEditarTarefa(BuildContext context, TimelineItemEntity item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TaskFormSheet(initialItem: item),
    );
  }

  void _abrirRemanejamento(BuildContext context, TimelineItemEntity item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RescheduleTaskSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PainelDiaState state = ref.watch(painelDiaNotifierProvider);
    final PainelDiaBundle bundle = state.bundle ??
        PainelDiaBundle.vazio(ref.watch(selectedDateStringProvider));

    final bool emAlertaFadiga = bundle.capacidadeDia.emAlertaFadiga;

    // Escuta erros para exibir SnackBar
    ref.listen<PainelDiaState>(painelDiaNotifierProvider, (previous, next) {
      if (next.hasError && previous?.failure != next.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure!.message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      }
    });

    final List<TimelineItemEntity> itensExibidos =
        state.abaDependencia == AbaDependencia.minhasAcoes
            ? bundle.itensLinhaTempo
            : bundle.itensEmEspera;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('nova_atividade_fab'),
        onPressed: () => _abrirFormNovaTarefa(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Atividade'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final String dateStr = ref.read(selectedDateStringProvider);
            if (state.visaoModo == VisaoModo.semana) {
              await ref
                  .read(painelDiaNotifierProvider.notifier)
                  .loadSemana(dateStr);
            } else {
              await ref.read(painelDiaNotifierProvider.notifier).loadDia(dateStr);
            }
          },
          child: CustomScrollView(
            slivers: <Widget>[
              // 1. Cabeçalho Principal (Saudação + Avatar)
              const SliverToBoxAdapter(child: PainelHeader()),

              // 2. Navegador de Datas (< Hoje >) + Seletor Dia / Semana
              const SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    DateNavigatorBar(),
                    SizedBox(height: AppSpacing.xs),
                    DayWeekSegmentedToggle(),
                    SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),

              // 3. Banner Alerta de Fadiga Mental (RN02)
              if (emAlertaFadiga && state.visaoModo == VisaoModo.dia)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.fatigueCritical.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.cardRadius,
                      border: Border.all(
                        color: AppColors.fatigueCritical.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.fatigueCritical,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Alerta de Fadiga Mental: ${bundle.capacidadeDia.percentualOcupacao}% do dia comprometido. Novos agendamentos bloqueados.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.fatigueCritical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. Se Visão da Semana estiver ativa:
              if (state.visaoModo == VisaoModo.semana)
                const SliverToBoxAdapter(child: WeeklyOverviewSection())
              else ...<Widget>[
                // 5. Filtro de Abas: Minhas Ações vs Em Espera
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          ChoiceChip(
                            key: const Key('tab_minhas_acoes'),
                            label: Text(
                              'Minhas Ações (${bundle.itensLinhaTempo.length})',
                            ),
                            selected: state.abaDependencia ==
                                AbaDependencia.minhasAcoes,
                            onSelected: (_) {
                              ref
                                  .read(painelDiaNotifierProvider.notifier)
                                  .setAbaDependencia(AbaDependencia.minhasAcoes);
                            },
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          ChoiceChip(
                            key: const Key('tab_em_espera'),
                            label: Text(
                              'Em Espera (${bundle.itensEmEspera.length})',
                            ),
                            selected:
                                state.abaDependencia == AbaDependencia.emEspera,
                            onSelected: (_) {
                              ref
                                  .read(painelDiaNotifierProvider.notifier)
                                  .setAbaDependencia(AbaDependencia.emEspera);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm)),

                // 6. Lista da Linha do Tempo
                if (state.isLoading && bundle.itensLinhaTempo.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (itensExibidos.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: state.abaDependencia == AbaDependencia.minhasAcoes
                          ? Icons.wb_sunny_outlined
                          : Icons.hourglass_empty_rounded,
                      title: state.abaDependencia == AbaDependencia.minhasAcoes
                          ? 'Nenhuma atividade para hoje'
                          : 'Nenhuma pendência em espera',
                      description: state.abaDependencia ==
                              AbaDependencia.minhasAcoes
                          ? 'Toque no botão + para agendar uma tarefa ou compromisso.'
                          : 'Tarefas dependendo de respostas de terceiros aparecerão aqui sem sobrecarregar sua linha do tempo.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.bottomFabPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = itensExibidos[index];
                          return TimelineSlotRow(
                            item: item,
                            onEdit: () => _abrirFormEditarTarefa(context, item),
                            onReschedule: () =>
                                _abrirRemanejamento(context, item),
                            onDelete: () {
                              ref
                                  .read(painelDiaNotifierProvider.notifier)
                                  .deleteTask(item.id);
                            },
                          );
                        },
                        childCount: itensExibidos.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
