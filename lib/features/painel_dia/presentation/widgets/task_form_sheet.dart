import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/selected_date_provider.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/fatigue_blocked_sheet.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/widgets/project_form_dialog.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({
    super.key,
    this.initialItem,
    this.initialDate,
    this.initialIndicadorDependencia,
  });

  final TimelineItemEntity? initialItem;
  final String? initialDate;
  final String? initialIndicadorDependencia;

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _customDurationController;
  late final TextEditingController _checklistTituloController;
  late final TextEditingController _checklistItemController;

  late String _tipoItem;
  late int _idPilar;
  late int _duracaoMinutos;
  late TaskPriority _prioridade;
  late String _indicadorDependencia;
  late String _dataAgendamento;
  String? _horarioInicio;
  String? _idProjeto;

  bool _temChecklist = false;
  String? _existingChecklistId;
  final List<String> _checklistItensNovos = <String>[];
  List<String> _checklistItensExistentes = <String>[];

  List<ProjetoEntity> _projetos = <ProjetoEntity>[];
  bool _isLoadingProjetos = true;
  bool _isSubmitting = false;

  static const List<PilarResumoEntity> _pilaresDisponiveis = <PilarResumoEntity>[
    PilarResumoEntity(idPilar: 1, codigo: 'SAUDE', nome: 'Saúde', corHex: '#22C55E', corFundoHex: '#F0FDF4', icone: 'heart_pulse'),
    PilarResumoEntity(idPilar: 2, codigo: 'MOVIMENTO', nome: 'Movimento', corHex: '#F97316', corFundoHex: '#FFF7ED', icone: 'activity'),
    PilarResumoEntity(idPilar: 3, codigo: 'SONO', nome: 'Sono', corHex: '#6366F1', corFundoHex: '#EEF2FF', icone: 'moon'),
    PilarResumoEntity(idPilar: 4, codigo: 'EQUILIBRIO_MENTAL', nome: 'Mente', corHex: '#EC4899', corFundoHex: '#FDF2F8', icone: 'brain'),
    PilarResumoEntity(idPilar: 5, codigo: 'ESTUDOS', nome: 'Estudos', corHex: '#10B981', corFundoHex: '#ECFDF5', icone: 'book_open'),
    PilarResumoEntity(idPilar: 6, codigo: 'FINANCAS', nome: 'Finanças', corHex: '#EAB308', corFundoHex: '#FEFCE8', icone: 'wallet'),
    PilarResumoEntity(idPilar: 7, codigo: 'CARREIRA', nome: 'Carreira', corHex: '#0EA5E9', corFundoHex: '#F0F9FF', icone: 'briefcase'),
  ];

  static const List<int> _duracoesPredefinidas = <int>[15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.nome ?? '');
    _descController = TextEditingController(text: item?.descricao ?? '');
    _customDurationController = TextEditingController();

    final existingChecklist =
        (item != null && item.checklists.isNotEmpty) ? item.checklists.first : null;
    _temChecklist = existingChecklist != null;
    _existingChecklistId = existingChecklist?.id;
    _checklistItensExistentes = existingChecklist != null
        ? existingChecklist.itens.map((i) => i.descricao).toList()
        : <String>[];
    _checklistTituloController = TextEditingController(
      text: existingChecklist?.titulo ?? '',
    );
    _checklistItemController = TextEditingController();

    _tipoItem = item?.tipoItem ?? 'TAREFA';
    _idPilar = item?.pilar.idPilar ?? 7;
    _duracaoMinutos = item?.duracaoEstimadaMinutos ?? 30;
    _prioridade = item?.prioridade ?? TaskPriority.prioridade;
    _indicadorDependencia = widget.initialIndicadorDependencia ??
        item?.indicadorDependencia ??
        'MINHAS_ACOES';
    _dataAgendamento =
        widget.initialDate ?? ref.read(selectedDateStringProvider);
    _horarioInicio = item?.horario;
    _idProjeto = item?.projeto?.id;

    _carregarProjetos();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _customDurationController.dispose();
    _checklistTituloController.dispose();
    _checklistItemController.dispose();
    super.dispose();
  }

  void _adicionarItemChecklist([String? valor]) {
    final String texto = (valor ?? _checklistItemController.text).trim();
    if (texto.isEmpty) return;
    setState(() {
      _checklistItensNovos.add(texto);
      _checklistItemController.clear();
    });
  }

  void _removerItemChecklistNovo(int index) {
    setState(() {
      _checklistItensNovos.removeAt(index);
    });
  }

  Future<void> _abrirDialogChecklistItens() async {
    final TextEditingController dialogItemCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void addFromDialog() {
              final String txt = dialogItemCtrl.text.trim();
              if (txt.isEmpty) return;
              setState(() {
                _checklistItensNovos.add(txt);
                _temChecklist = true;
              });
              setDialogState(() {
                dialogItemCtrl.clear();
              });
            }

            return AlertDialog(
              title: Row(
                children: <Widget>[
                  const Icon(
                    Icons.checklist_rounded,
                    color: AppColors.primaryBrand,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Lista de Itens (Checklist)',
                      style: AppTypography.cardTitle,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        controller: _checklistTituloController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da lista (opcional)',
                          hintText: 'Ex: Lista de Compras, Passo a passo',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              key: const Key('dialog_checklist_item_input'),
                              controller: dialogItemCtrl,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'Novo item da lista',
                                hintText: 'Ex: Leite, Pão, Frutas...',
                                isDense: true,
                              ),
                              onSubmitted: (_) => addFromDialog(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton.filled(
                            key: const Key('dialog_add_checklist_item_btn'),
                            onPressed: addFromDialog,
                            icon: const Icon(Icons.add_rounded),
                            tooltip: 'Adicionar item',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_checklistItensExistentes.isEmpty &&
                          _checklistItensNovos.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            'Nenhum item adicionado ainda. Digite acima e toque em +.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else ...<Widget>[
                        ..._checklistItensExistentes.map(
                          (desc) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            title: Text(desc, style: AppTypography.bodyMedium),
                          ),
                        ),
                        ..._checklistItensNovos.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final String desc = entry.value;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: AppColors.primaryBrand,
                            ),
                            title: Text(
                              desc,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.fatigueCritical,
                              ),
                              onPressed: () {
                                setState(() {
                                  _checklistItensNovos.removeAt(idx);
                                });
                                setDialogState(() {});
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Concluir Lista'),
                ),
              ],
            );
          },
        );
      },
    );
    dialogItemCtrl.dispose();
  }

  Future<void> _carregarProjetos() async {
    final result = await ref.read(painelRepositoryProvider).getProjetos();
    if (!mounted) return;
    result.fold(
      onFailure: (_) => setState(() => _isLoadingProjetos = false),
      onSuccess: (list) {
        setState(() {
          _projetos = list;
          _isLoadingProjetos = false;
        });
      },
    );
  }

  Future<void> _abrirNovoProjetoDialog() async {
    final ProjetoEntity? novo = await showDialog<ProjetoEntity>(
      context: context,
      builder: (context) => const ProjectFormDialog(),
    );
    if (novo != null && mounted) {
      setState(() {
        _projetos = <ProjetoEntity>[..._projetos, novo];
        _idProjeto = novo.id;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Se o usuário deixou algo digitado no campo de item de checklist sem clicar no '+', adiciona automaticamente
    if (_temChecklist && _checklistItemController.text.trim().isNotEmpty) {
      _adicionarItemChecklist();
    }

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'nome': _nameController.text.trim(),
      'duracaoEstimadaMinutos': _duracaoMinutos,
      'idPilar': _idPilar,
      'prioridade': _prioridade.apiCode,
      'indicadorDependencia': _indicadorDependencia,
      'dataAgendamento': _dataAgendamento,
      'tipoItem': _tipoItem,
      if (_descController.text.trim().isNotEmpty)
        'descricao': _descController.text.trim(),
      if (_horarioInicio != null && _horarioInicio!.isNotEmpty)
        'horarioInicio': _horarioInicio,
      if (_idProjeto != null) 'idProjeto': _idProjeto,
    };

    final notifier = ref.read(painelDiaNotifierProvider.notifier);
    final repo = ref.read(painelRepositoryProvider);
    bool ok = false;
    String? targetTaskId;

    if (widget.initialItem != null) {
      ok = await notifier.updateTask(widget.initialItem!.id, payload);
      targetTaskId = widget.initialItem!.id;
    } else {
      final createdId = await notifier.createTaskWithId(payload);
      ok = createdId != null;
      targetTaskId = createdId;
    }

    if (ok &&
        _temChecklist &&
        _checklistItensNovos.isNotEmpty &&
        targetTaskId != null &&
        targetTaskId.isNotEmpty) {
      if (_existingChecklistId != null) {
        for (final String desc in _checklistItensNovos) {
          await repo.addChecklistItem(
            idChecklist: _existingChecklistId!,
            descricao: desc,
          );
        }
      } else {
        final String tituloChecklist =
            _checklistTituloController.text.trim().isNotEmpty
                ? _checklistTituloController.text.trim()
                : _nameController.text.trim();

        await repo.createChecklist(<String, dynamic>{
          'titulo': tituloChecklist,
          'idTarefa': targetTaskId,
          'ehModelo': false,
          'itens': _checklistItensNovos.asMap().entries.map((entry) {
            return <String, dynamic>{
              'descricao': entry.value,
              'ordem': entry.key + 1,
            };
          }).toList(),
        });
      }
      final String dateStr = ref.read(selectedDateStringProvider);
      await notifier.loadDia(dateStr);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      final failure = ref.read(painelDiaNotifierProvider).failure;
      if (failure is MentalFatigueBlockedFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surfaceCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => FatigueBlockedSheet(
            dataAtual: _dataAgendamento,
            onAgendarEmDataLivre: (dataLivre) {
              setState(() {
                _dataAgendamento = dataLivre;
              });
            },
            onRegistrarEmEspera: () {
              setState(() {
                _indicadorDependencia = 'EM_ESPERA';
              });
            },
          ),
        );
      } else {
        final msg = failure?.message ?? 'Erro ao salvar tarefa.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Indicador de arraste
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.initialItem != null
                          ? 'Editar Atividade'
                          : 'Nova Atividade',
                      style: AppTypography.displayLarge.copyWith(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    key: const Key('close_task_sheet_button'),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Data agendada: $_dataAgendamento',
                style: AppTypography.chipLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Tipo: Tarefa vs Compromisso
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'TAREFA',
                    label: Text('Tarefa'),
                    icon: Icon(Icons.task_alt_rounded),
                  ),
                  ButtonSegment<String>(
                    value: 'COMPROMISSO',
                    label: Text('Compromisso'),
                    icon: Icon(Icons.event_rounded),
                  ),
                ],
                selected: <String>{_tipoItem},
                onSelectionChanged: (set) {
                  setState(() => _tipoItem = set.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Nome
              TextFormField(
                key: const Key('task_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da atividade *',
                  hintText: 'Ex: Revisar relatório mensal',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome da atividade.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Descrição
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Detalhes ou links úteis',
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Pilar Obrigatório (1..7)
              Text('Pilar de Vida *', style: AppTypography.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _pilaresDisponiveis.map((p) {
                  final bool isSelected = p.idPilar == _idPilar;
                  return PilarChip(
                    nome: p.nome,
                    corHex: p.corHex,
                    corFundoHex: p.corFundoHex,
                    icone: p.icone,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _idPilar = p.idPilar);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Duração estimada em minutos
              Text('Duração Estimada *', style: AppTypography.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: _duracoesPredefinidas.map((dur) {
                  final bool isSelected = _duracaoMinutos == dur;
                  return ChoiceChip(
                    label: Text('$dur min'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _duracaoMinutos = dur);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Horário e Prioridade
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _horarioInicio != null
                              ? TimeOfDay(
                                  hour: int.parse(_horarioInicio!.split(':')[0]),
                                  minute: int.parse(_horarioInicio!.split(':')[1]),
                                )
                              : const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            _horarioInicio =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(_horarioInicio ?? 'Sem horário'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      initialValue: _prioridade,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                      ),
                      items: TaskPriority.values.map((pr) {
                        return DropdownMenuItem<TaskPriority>(
                          value: pr,
                          child: Text(pr.label),
                        );
                      }).toList(),
                      onChanged: (pr) {
                        if (pr != null) setState(() => _prioridade = pr);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Dependência: Minhas Ações vs Em Espera
              Text('Dependência', style: AppTypography.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'MINHAS_ACOES',
                    label: Text('Minhas Ações'),
                    icon: Icon(Icons.person_rounded),
                  ),
                  ButtonSegment<String>(
                    value: 'EM_ESPERA',
                    label: Text('Em Espera (Terceiros)'),
                    icon: Icon(Icons.hourglass_empty_rounded),
                  ),
                ],
                selected: <String>{_indicadorDependencia},
                onSelectionChanged: (set) {
                  setState(() => _indicadorDependencia = set.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Projeto Associado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Projeto (Opcional)', style: AppTypography.cardTitle),
                  TextButton.icon(
                    onPressed: _abrirNovoProjetoDialog,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Novo Projeto'),
                  ),
                ],
              ),
              if (_isLoadingProjetos)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String?>(
                  initialValue: _idProjeto,
                  decoration: const InputDecoration(
                    labelText: 'Selecione um projeto',
                    isDense: true,
                  ),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Nenhum projeto'),
                    ),
                    ..._projetos.map((proj) {
                      return DropdownMenuItem<String?>(
                        value: proj.id,
                        child: Text(proj.nome),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _idProjeto = val);
                  },
                ),
              const SizedBox(height: AppSpacing.md),

              // Checklist (Lista de itens) — RF19 / RF20
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _temChecklist
                      ? AppColors.primaryBrand.withValues(alpha: 0.05)
                      : AppColors.surfaceSubtle.withValues(alpha: 0.5),
                  borderRadius: AppSpacing.inputRadius,
                  border: Border.all(
                    color: _temChecklist
                        ? AppColors.primaryBrand
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        FilterChip(
                          key: const Key('toggle_checklist_button'),
                          avatar: Icon(
                            Icons.checklist_rounded,
                            size: 18,
                            color: _temChecklist
                                ? Colors.white
                                : AppColors.primaryBrand,
                          ),
                          label: const Text('Checklist (Lista de itens)'),
                          selected: _temChecklist,
                          selectedColor: AppColors.primaryBrand,
                          checkmarkColor: Colors.white,
                          labelStyle: AppTypography.labelLarge.copyWith(
                            color: _temChecklist
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              _temChecklist = selected;
                            });
                          },
                        ),
                        const Spacer(),
                        if (_temChecklist)
                          TextButton.icon(
                            key: const Key('open_checklist_dialog_button'),
                            onPressed: _abrirDialogChecklistItens,
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                            ),
                            label: const Text('Abrir Lista'),
                          ),
                      ],
                    ),
                    if (_temChecklist) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Adicione os itens da lista (ex: compras de mercado, etapas da tarefa):',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              key: const Key('checklist_item_input'),
                              controller: _checklistItemController,
                              decoration: const InputDecoration(
                                hintText: 'Adicionar item (ex: Leite, Pão...)',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _adicionarItemChecklist(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton.filled(
                            key: const Key('add_checklist_item_button'),
                            onPressed: _adicionarItemChecklist,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            tooltip: 'Adicionar à lista',
                          ),
                        ],
                      ),
                      if (_checklistItensExistentes.isNotEmpty ||
                          _checklistItensNovos.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        ..._checklistItensExistentes.map(
                          (desc) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    desc,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ..._checklistItensNovos.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final String desc = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.check_box_outline_blank_rounded,
                                  size: 16,
                                  color: AppColors.primaryBrand,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    desc,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  key: Key('remove_checklist_item_$idx'),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: AppColors.fatigueCritical,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Remover item',
                                  onPressed: () =>
                                      _removerItemChecklistNovo(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Botão Salvar
              PrimaryGradientButton(
                key: const Key('save_task_button'),
                label: widget.initialItem != null
                    ? 'Atualizar Atividade'
                    : 'Salvar Atividade',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Botão Cancelar explícito
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('cancel_task_button'),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
