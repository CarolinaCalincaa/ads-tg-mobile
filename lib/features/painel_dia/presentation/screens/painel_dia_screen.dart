import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/pending_closing_callout.dart';
import 'package:produtividade_tcc/features/habitos/presentation/widgets/habit_form_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/active_pillars_filter_row.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/active_pomodoro_mini_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/compact_capacity_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/date_navigator_bar.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/day_week_segmented_toggle.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/fadiga_alert_banner.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/fatigue_blocked_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/painel_header.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/reschedule_task_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/smart_schedule_fab.dart';
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

  void _abrirFormEditarAtividade(BuildContext context, TimelineItemEntity item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => item.ehHabito
          ? HabitFormSheet(initialItem: item)
          : TaskFormSheet(initialItem: item),
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

  void _abrirFatigueBlockedSheet(BuildContext context, String dataAtual) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FatigueBlockedSheet(
        dataAtual: dataAtual,
        onAgendarEmDataLivre: (dataLivre) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.surfaceCard,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => TaskFormSheet(initialDate: dataLivre),
          );
        },
        onRegistrarEmEspera: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.surfaceCard,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => const TaskFormSheet(
              initialIndicadorDependencia: 'EM_ESPERA',
            ),
          );
        },
        onDesafogarHoje: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Toque no menu ⋮ de qualquer atividade para remanejá-la para outra data.',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PainelDiaState state = ref.watch(painelDiaNotifierProvider);
    final DateTime selectedDate = ref.watch(selectedDateProvider);
    final String dataAtual = ref.watch(selectedDateStringProvider);
    final PainelDiaBundle bundle = state.bundle ?? PainelDiaBundle.vazio(dataAtual);

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

    final List<TimelineItemEntity> baseItens =
        state.abaDependencia == AbaDependencia.minhasAcoes
            ? bundle.itensLinhaTempo
            : bundle.itensEmEspera;

    final List<TimelineItemEntity> itensExibidos =
        state.selectedPilarFilter != null
            ? baseItens
                .where((i) => i.pilar.idPilar == state.selectedPilarFilter)
                .toList()
            : baseItens;

    return Scaffold(
      floatingActionButton: SmartScheduleFab(
        novosAgendamentosBloqueados:
            bundle.capacidadeDia.novosAgendamentosBloqueados,
        onNovaAtividade: () => _abrirFormNovaTarefa(context),
        onBloqueadoTap: () => _abrirFatigueBlockedSheet(context, dataAtual),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final String dateStr = ref.read(selectedDateStringProvider);
                  if (state.visaoModo == VisaoModo.semana) {
                    await ref
                        .read(painelDiaNotifierProvider.notifier)
                        .loadSemana(dateStr);
                  } else {
                    await ref
                        .read(painelDiaNotifierProvider.notifier)
                        .loadDia(dateStr);
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

                    // 2.1 Pilares Ativos Focais do Mês (RF12 / RN01 — Mockup 01)
                    SliverToBoxAdapter(
                      child: ActivePillarsFilterRow(
                        pilaresAtivos: bundle.pilaresAtivosMes,
                      ),
                    ),

                    // 2.2 Banner Contextual de Fechamento Reflexivo (E06-T04 — Domingos ou fim de mês)
                    if (PendingClosingCallout.shouldShowForDate(selectedDate))
                      SliverToBoxAdapter(
                        child: PendingClosingCallout(
                          onTap: () {
                            context.push(
                              '${AppRoutes.fechamento}?tipoCiclo=${selectedDate.weekday == DateTime.sunday ? 'SEMANAL' : 'MENSAL'}&dataRef=$dataAtual',
                            );
                          },
                        ),
                      ),

                    // 3. Capacidade Diária / Banner Alerta de Fadiga Mental (RN02 / RF16 / RF17)
                    if (state.visaoModo == VisaoModo.dia)
                      SliverToBoxAdapter(
                        child: emAlertaFadiga
                            ? FadigaAlertBanner(
                                capacidade: bundle.capacidadeDia,
                                onRemanejar: () => _abrirFatigueBlockedSheet(
                                  context,
                                  dataAtual,
                                ),
                              )
                            : CompactCapacityBar(
                                capacidade: bundle.capacidadeDia,
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
                            onEdit: () => _abrirFormEditarAtividade(context, item),
                            onReschedule: () =>
                                _abrirRemanejamento(context, item),
                            onDelete: () {
                              if (item.ehHabito) {
                                ref
                                    .read(painelDiaNotifierProvider.notifier)
                                    .deleteHabit(item.id);
                              } else {
                                ref
                                    .read(painelDiaNotifierProvider.notifier)
                                    .deleteTask(item.id);
                              }
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
      const ActivePomodoroMiniBar(),
    ],
  ),
),
    );
  }
}
