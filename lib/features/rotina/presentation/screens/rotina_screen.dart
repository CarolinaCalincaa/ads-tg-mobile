import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/features/habitos/presentation/widgets/habit_form_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/reschedule_task_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/task_form_sheet.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';
import 'package:produtividade_tcc/features/rotina/presentation/providers/rotina_notifier.dart';
import 'package:produtividade_tcc/features/rotina/presentation/widgets/rotina_item_cards.dart';

/// Aba 3: Centro de Controle da Rotina — Visão unificada por Tarefas, Hábitos e Em Espera.
class RotinaScreen extends ConsumerStatefulWidget {
  const RotinaScreen({super.key});

  @override
  ConsumerState<RotinaScreen> createState() => _RotinaScreenState();
}

class _RotinaScreenState extends ConsumerState<RotinaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _abrirNovaTarefa({String? indicadorDependencia}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(
        initialIndicadorDependencia: indicadorDependencia,
      ),
    );
    if (mounted) {
      ref.read(rotinaNotifierProvider.notifier).carregarTudo();
    }
  }

  Future<void> _abrirNovoHabito() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const HabitFormSheet(),
    );
    if (mounted) {
      ref.read(rotinaNotifierProvider.notifier).carregarTudo();
    }
  }

  Future<void> _abrirEdicaoTarefa(RotinaTarefaEntity tarefa) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(initialItem: tarefa.toTimelineItem()),
    );
    if (mounted) {
      ref.read(rotinaNotifierProvider.notifier).carregarTudo();
    }
  }

  Future<void> _abrirReagendamentoTarefa(RotinaTarefaEntity tarefa) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RescheduleTaskSheet(item: tarefa.toTimelineItem()),
    );
    if (mounted) {
      ref.read(rotinaNotifierProvider.notifier).carregarTudo();
    }
  }

  Future<void> _abrirEdicaoHabito(RotinaHabitoEntity habito) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HabitFormSheet(initialItem: habito.toTimelineItem()),
    );
    if (mounted) {
      ref.read(rotinaNotifierProvider.notifier).carregarTudo();
    }
  }

  void _abrirMenuCriacaoRapida() {
    final RotinaSegmento seg = ref.read(rotinaNotifierProvider).segmento;
    if (seg == RotinaSegmento.habitos) {
      _abrirNovoHabito();
      return;
    }
    if (seg == RotinaSegmento.emEspera) {
      _abrirNovaTarefa(indicadorDependencia: 'EM_ESPERA');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Adicionar à Rotina',
                  style: AppTypography.displayTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  key: const Key('rotina_quick_add_task'),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.pilarSonoBg,
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                  title: const Text('Nova Tarefa ou Compromisso'),
                  subtitle: const Text(
                    'Agende uma atividade pontual vinculada a um pilar',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _abrirNovaTarefa();
                  },
                ),
                ListTile(
                  key: const Key('rotina_quick_add_habit'),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(
                      Icons.repeat_rounded,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                  title: const Text('Novo Hábito Recorrente'),
                  subtitle: const Text(
                    'Defina dias da semana e construa consistência diária',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _abrirNovoHabito();
                  },
                ),
                ListTile(
                  key: const Key('rotina_quick_add_waiting'),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(
                      Icons.hourglass_top_rounded,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  title: const Text('Registrar Item Em Espera'),
                  subtitle: const Text(
                    'Atividade que depende de terceiros (sem ocupar horas úteis)',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _abrirNovaTarefa(indicadorDependencia: 'EM_ESPERA');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final RotinaState state = ref.watch(rotinaNotifierProvider);
    final RotinaNotifier notifier = ref.read(rotinaNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Controle da Rotina'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            key: const Key('rotina_btn_modelos_processos'),
            tooltip: 'Modelos de Processos (Checklists)',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => context.push(AppRoutes.modelosProcessos),
          ),
          IconButton(
            key: const Key('rotina_btn_pilares_mensais'),
            tooltip: 'Pilares do Mês',
            icon: const Icon(Icons.auto_awesome_mosaic_outlined),
            onPressed: () => context.push(AppRoutes.pilaresMensais),
          ),
          IconButton(
            key: const Key('rotina_btn_recarregar'),
            tooltip: 'Atualizar lista',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.carregarTudo,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('rotina_fab_adicionar'),
        backgroundColor: AppColors.primaryBrand,
        foregroundColor: Colors.white,
        onPressed: _abrirMenuCriacaoRapida,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          switch (state.segmento) {
            RotinaSegmento.tarefas => 'Adicionar',
            RotinaSegmento.habitos => 'Novo Hábito',
            RotinaSegmento.emEspera => 'Novo Em Espera',
          },
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.carregarTudo,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              96,
            ),
            children: <Widget>[
              // Subtítulo do Centro de Controle
              Text(
                'Visão global de todas as suas atividades e hábitos cadastrados, independente da data.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 1. Cards de Resumo (KPIs)
              _buildSummaryGrid(state),
              const SizedBox(height: AppSpacing.md),

              // 2. Seletor de Segmento Principal (Tarefas | Hábitos | Em Espera)
              SegmentedButton<RotinaSegmento>(
                key: const Key('rotina_segmented_control'),
                segments: <ButtonSegment<RotinaSegmento>>[
                  ButtonSegment<RotinaSegmento>(
                    value: RotinaSegmento.tarefas,
                    icon: const Icon(Icons.task_alt_rounded, size: 18),
                    label: Text('Tarefas (${state.minhasAcoes.length})'),
                  ),
                  ButtonSegment<RotinaSegmento>(
                    value: RotinaSegmento.habitos,
                    icon: const Icon(Icons.repeat_rounded, size: 18),
                    label: Text('Hábitos (${state.habitos.length})'),
                  ),
                  ButtonSegment<RotinaSegmento>(
                    value: RotinaSegmento.emEspera,
                    icon: const Icon(Icons.hourglass_empty_rounded, size: 18),
                    label: Text('Em Espera (${state.tarefasEmEspera.length})'),
                  ),
                ],
                selected: <RotinaSegmento>{state.segmento},
                onSelectionChanged: (Set<RotinaSegmento> sel) {
                  notifier.selecionarSegmento(sel.first);
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Barra de Busca
              TextField(
                key: const Key('rotina_search_field'),
                controller: _searchController,
                onChanged: notifier.atualizarBusca,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, projeto ou pilar...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: state.busca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            notifier.atualizarBusca('');
                          },
                        )
                      : null,
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 4. Filtro Horizontal por Pilar
              _buildPilarFilterRow(state, notifier),
              const SizedBox(height: AppSpacing.xs),

              // 5. Sub-filtros contextuais (Status da Tarefa ou Apenas Hábitos Ativos)
              if (state.segmento == RotinaSegmento.tarefas)
                _buildTaskStatusFilterRow(state, notifier)
              else if (state.segmento == RotinaSegmento.habitos)
                _buildHabitSubFilterRow(state, notifier),

              const SizedBox(height: AppSpacing.sm),

              // 6. Conteúdo da Lista
              if (state.isLoading &&
                  state.tarefas.isEmpty &&
                  state.habitos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.segmento == RotinaSegmento.habitos)
                _buildHabitosList(state, notifier)
              else
                _buildTarefasList(state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(RotinaState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SummaryMetricTile(
            key: const Key('rotina_kpi_pendentes'),
            label: 'Pendentes',
            value: '${state.totalPendentes}',
            icon: Icons.pending_actions_rounded,
            color: AppColors.primaryBrand,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _SummaryMetricTile(
            key: const Key('rotina_kpi_concluidas'),
            label: 'Concluídas',
            value: '${state.totalConcluidas}',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.capacityHealthy,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _SummaryMetricTile(
            key: const Key('rotina_kpi_habitos'),
            label: 'Hábitos Ativos',
            value: '${state.totalHabitosAtivos}',
            icon: Icons.repeat_rounded,
            color: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _SummaryMetricTile(
            key: const Key('rotina_kpi_streak'),
            label: 'Maior Streak',
            value: '${state.maiorStreakHabitos}d 🔥',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEA580C),
          ),
        ),
      ],
    );
  }

  Widget _buildPilarFilterRow(RotinaState state, RotinaNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          FilterChip(
            key: const Key('rotina_filter_pilar_todos'),
            label: const Text('Todos os Pilares'),
            selected: state.filtroPilarId == null,
            onSelected: (_) => notifier.selecionarFiltroPilar(null),
          ),
          const SizedBox(width: 6),
          ...PilarEntity.pilaresMestresCanonicos.map((PilarEntity pilar) {
            final bool isSelected = state.filtroPilarId == pilar.id;
            final Color color = AppColors.fromHex(pilar.corHex);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                key: Key('rotina_filter_pilar_${pilar.id}'),
                avatar: Icon(
                  PilarChip.resolveIcon(pilar.icone),
                  size: 14,
                  color: isSelected ? Colors.white : color,
                ),
                label: Text(pilar.nome),
                selected: isSelected,
                selectedColor: color,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                onSelected: (_) => notifier.selecionarFiltroPilar(pilar.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskStatusFilterRow(
    RotinaState state,
    RotinaNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ChoiceChip(
            key: const Key('rotina_status_todas'),
            label: const Text('Todas'),
            selected: state.filtroStatusTarefa == RotinaFiltroStatusTarefa.todas,
            onSelected: (_) => notifier.selecionarFiltroStatusTarefa(
              RotinaFiltroStatusTarefa.todas,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('rotina_status_pendentes'),
            label: const Text('Pendentes'),
            selected:
                state.filtroStatusTarefa == RotinaFiltroStatusTarefa.pendentes,
            onSelected: (_) => notifier.selecionarFiltroStatusTarefa(
              RotinaFiltroStatusTarefa.pendentes,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: const Key('rotina_status_concluidas'),
            label: const Text('Concluídas'),
            selected:
                state.filtroStatusTarefa == RotinaFiltroStatusTarefa.concluidas,
            onSelected: (_) => notifier.selecionarFiltroStatusTarefa(
              RotinaFiltroStatusTarefa.concluidas,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitSubFilterRow(
    RotinaState state,
    RotinaNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Exibir apenas hábitos ativos',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Switch.adaptive(
          key: const Key('rotina_switch_apenas_habitos_ativos'),
          value: state.apenasHabitosAtivos,
          activeTrackColor: AppColors.primaryBrand,
          onChanged: notifier.alternarApenasHabitosAtivos,
        ),
      ],
    );
  }

  Widget _buildTarefasList(RotinaState state, RotinaNotifier notifier) {
    final List<RotinaTarefaEntity> lista = state.tarefasFiltradas;

    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: EmptyStateView(
          icon: state.segmento == RotinaSegmento.emEspera
              ? Icons.hourglass_empty_rounded
              : Icons.task_alt_rounded,
          title: state.segmento == RotinaSegmento.emEspera
              ? 'Nenhuma atividade em espera'
              : 'Nenhuma tarefa encontrada',
          description: state.segmento == RotinaSegmento.emEspera
              ? 'Registre aqui atividades delegadas ou que aguardam resposta de terceiros.'
              : 'Você pode cadastrar novas tarefas ou limpar os filtros ativos.',
        ),
      );
    }

    return Column(
      children: lista
          .map(
            (RotinaTarefaEntity tarefa) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RotinaTaskCard(
                tarefa: tarefa,
                onToggleStatus: () => notifier.toggleTarefaStatus(tarefa.id),
                onEdit: () => _abrirEdicaoTarefa(tarefa),
                onReschedule: () => _abrirReagendamentoTarefa(tarefa),
                onDelete: () => notifier.excluirTarefa(tarefa.id),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHabitosList(RotinaState state, RotinaNotifier notifier) {
    final List<RotinaHabitoEntity> lista = state.habitosFiltrados;

    if (lista.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: EmptyStateView(
          icon: Icons.repeat_rounded,
          title: 'Nenhum hábito cadastrado',
          description:
              'Crie hábitos recorrentes nos seus pilares de vida para acompanhar suas sequências (streaks).',
        ),
      );
    }

    return Column(
      children: lista
          .map(
            (RotinaHabitoEntity habito) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RotinaHabitCard(
                habito: habito,
                onToggleAtivo: (bool val) =>
                    notifier.toggleHabitoAtivo(habito.id, val),
                onEdit: () => _abrirEdicaoHabito(habito),
                onDelete: () => notifier.excluirHabito(habito.id),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  const _SummaryMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.chipLabel.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
