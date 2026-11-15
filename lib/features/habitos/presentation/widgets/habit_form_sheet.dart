import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';

/// Modal para Criação e Edição de Hábitos Recorrentes (`RF06`, `RF08`, `RF13`, `RF15`).
class HabitFormSheet extends ConsumerStatefulWidget {
  const HabitFormSheet({
    super.key,
    this.initialItem,
  });

  final TimelineItemEntity? initialItem;

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _duracaoController;

  int _selectedPilarId = 2; // Padrão: Movimento
  late Set<int> _selectedDiasSemana; // 1=Seg..7=Dom
  String? _horarioPadrao; // 'HH:mm'
  bool _isSaving = false;
  String? _submitError;

  static const List<Map<String, dynamic>> _diasSemanaLabels = <Map<String, dynamic>>[
    <String, dynamic>{'dia': 1, 'sigla': 'S', 'nome': 'Seg'},
    <String, dynamic>{'dia': 2, 'sigla': 'T', 'nome': 'Ter'},
    <String, dynamic>{'dia': 3, 'sigla': 'Q', 'nome': 'Qua'},
    <String, dynamic>{'dia': 4, 'sigla': 'Q', 'nome': 'Qui'},
    <String, dynamic>{'dia': 5, 'sigla': 'S', 'nome': 'Sex'},
    <String, dynamic>{'dia': 6, 'sigla': 'S', 'nome': 'Sáb'},
    <String, dynamic>{'dia': 7, 'sigla': 'D', 'nome': 'Dom'},
  ];

  @override
  void initState() {
    super.initState();
    final TimelineItemEntity? item = widget.initialItem;

    _nomeController = TextEditingController(text: item?.nome ?? '');
    _descricaoController = TextEditingController(text: item?.descricao ?? '');
    _duracaoController = TextEditingController(
      text: (item?.duracaoEstimadaMinutos ?? 30).toString(),
    );

    _selectedPilarId = item?.pilar.idPilar ?? 2;
    _selectedDiasSemana = item?.diasSemana != null && item!.diasSemana!.isNotEmpty
        ? item.diasSemana!.toSet()
        : <int>{1, 2, 3, 4, 5, 6, 7};
    _horarioPadrao = item?.horario;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _duracaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarHorario() async {
    final TimeOfDay initial = _horarioPadrao != null && _horarioPadrao!.contains(':')
        ? TimeOfDay(
            hour: int.tryParse(_horarioPadrao!.split(':')[0]) ?? 7,
            minute: int.tryParse(_horarioPadrao!.split(':')[1]) ?? 0,
          )
        : const TimeOfDay(hour: 7, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final String hh = picked.hour.toString().padLeft(2, '0');
      final String mm = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _horarioPadrao = '$hh:$mm';
      });
    }
  }

  Future<void> _salvar() async {
    setState(() => _submitError = null);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDiasSemana.isEmpty) {
      setState(() {
        _submitError = 'Selecione pelo menos um dia da semana para o hábito.';
      });
      return;
    }

    setState(() => _isSaving = true);

    final int duracao = int.tryParse(_duracaoController.text.trim()) ?? 30;
    final String desc = _descricaoController.text.trim();
    final List<int> diasOrdenados = _selectedDiasSemana.toList()..sort();

    // Envia apenas os campos aceitos pelo CreateHabitoDto / UpdateHabitoDto (sem nulos rejeitados)
    final Map<String, dynamic> payload = <String, dynamic>{
      'nome': _nomeController.text.trim(),
      'idPilar': _selectedPilarId,
      'duracaoEstimadaMinutos': duracao,
      'frequenciaSemanal': diasOrdenados.length,
      'diasSemana': diasOrdenados,
      if (desc.isNotEmpty) 'descricao': desc,
      if (_horarioPadrao != null && _horarioPadrao!.trim().isNotEmpty)
        'horarioPadrao': _horarioPadrao!.trim(),
    };

    final PainelDiaNotifier notifier =
        ref.read(painelDiaNotifierProvider.notifier);

    final bool isEditing = widget.initialItem != null;
    final bool success;
    if (isEditing) {
      success = await notifier.updateHabit(widget.initialItem!.id, payload);
    } else {
      success = await notifier.createHabit(payload);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      final ScaffoldMessengerState? messenger =
          ScaffoldMessenger.maybeOf(context);
      Navigator.of(context).pop();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Hábito atualizado com sucesso!'
                : 'Hábito recorrente criado com sucesso!',
          ),
          backgroundColor: AppColors.capacityHealthy,
        ),
      );
    } else {
      final String errorMsg =
          ref.read(painelDiaNotifierProvider).failure?.message ??
              'Não foi possível salvar o hábito. Verifique sua conexão.';
      setState(() => _submitError = errorMsg);
    }
  }

  Future<void> _excluir() async {
    if (widget.initialItem == null) return;
    setState(() {
      _isSaving = true;
      _submitError = null;
    });

    final bool success = await ref
        .read(painelDiaNotifierProvider.notifier)
        .deleteHabit(widget.initialItem!.id);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      final String errorMsg =
          ref.read(painelDiaNotifierProvider).failure?.message ??
              'Erro ao excluir o hábito.';
      setState(() => _submitError = errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialItem != null;
    final List<PilarResumoEntity> pilaresAtivos =
        ref.watch(painelDiaNotifierProvider).bundle?.pilaresAtivosMes ??
            <PilarResumoEntity>[];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título do modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      isEditing ? 'Editar Hábito' : 'Novo Hábito Recorrente',
                      style: AppTypography.displayLarge.copyWith(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    key: const Key('close_habit_sheet_button'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_submitError != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.fatigueCritical.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.inputRadius,
                    border: Border.all(color: AppColors.fatigueCritical),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.fatigueCritical,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _submitError!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.fatigueCritical,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Nome
              TextFormField(
                key: const Key('habit_name_field'),
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hábito *',
                  hintText: 'Ex: Corrida matinal, Leitura de 20 páginas',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome do hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Descrição
              TextFormField(
                key: const Key('habit_desc_field'),
                controller: _descricaoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Instruções ou detalhes do hábito',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Pilar Obrigatório com destaque para os 3 ativos do mês
              Text(
                'Pilar de Vida Obrigatório *',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: PilarEntity.pilaresMestresCanonicos.map((pilar) {
                  final bool isSelected = _selectedPilarId == pilar.id;
                  final bool isFocalMes = pilaresAtivos.any(
                    (p) => p.idPilar == pilar.id,
                  );

                  return ChoiceChip(
                    key: Key('habit_pilar_chip_${pilar.id}'),
                    avatar: Icon(
                      PilarChip.resolveIcon(pilar.icone),
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : AppColors.fromHex(pilar.corHex),
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(pilar.nome),
                        if (isFocalMes) ...<Widget>[
                          const SizedBox(width: 4),
                          const Text('⭐', style: TextStyle(fontSize: 10)),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.fromHex(pilar.corHex),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isFocalMes ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedPilarId = pilar.id;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Seletor de Dias da Semana (S T Q Q S S D)
              Text(
                'Dias da Semana Recorrentes *',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _diasSemanaLabels.map((info) {
                  final int dia = info['dia'] as int;
                  final String sigla = info['sigla'] as String;
                  final bool isDaySelected = _selectedDiasSemana.contains(dia);

                  return InkWell(
                    key: Key('dia_semana_btn_$dia'),
                    onTap: () {
                      setState(() {
                        if (isDaySelected) {
                          _selectedDiasSemana.remove(dia);
                        } else {
                          _selectedDiasSemana.add(dia);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDaySelected
                            ? AppColors.primaryBrand
                            : AppColors.surfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDaySelected
                              ? AppColors.primaryBrand
                              : AppColors.borderSubtle,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sigla,
                        style: TextStyle(
                          color: isDaySelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Duração e Horário
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: const Key('habit_duracao_field'),
                      controller: _duracaoController,
                      decoration: const InputDecoration(
                        labelText: 'Duração (min) *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final int? n = int.tryParse(val ?? '');
                        if (n == null || n <= 0) {
                          return 'Minutos válidos';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('habit_time_picker_button'),
                      onPressed: _selecionarHorario,
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(
                        _horarioPadrao ?? 'Horário sugerido',
                        style: AppTypography.bodyMedium,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.chipRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Botões de Ação
              PrimaryGradientButton(
                key: const Key('save_habit_button'),
                label: isEditing ? 'Salvar Alterações' : 'Criar Hábito',
                isLoading: _isSaving,
                onPressed: _salvar,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Botão Cancelar explícito
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('cancel_habit_button'),
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),

              if (isEditing) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  key: const Key('delete_habit_button'),
                  onPressed: _isSaving ? null : _excluir,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.fatigueCritical,
                    size: 18,
                  ),
                  label: const Text(
                    'Excluir Hábito',
                    style: TextStyle(color: AppColors.fatigueCritical),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
