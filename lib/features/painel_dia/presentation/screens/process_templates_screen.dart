import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/empty_state_view.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';

class ProcessTemplatesScreen extends ConsumerStatefulWidget {
  const ProcessTemplatesScreen({super.key});

  @override
  ConsumerState<ProcessTemplatesScreen> createState() =>
      _ProcessTemplatesScreenState();
}

class _ProcessTemplatesScreenState
    extends ConsumerState<ProcessTemplatesScreen> {
  List<ChecklistEntity> _templates = <ChecklistEntity>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final result = await ref
        .read(painelRepositoryProvider)
        .getChecklists(ehModelo: true);

    if (!mounted) return;
    result.fold(
      onFailure: (_) => setState(() => _isLoading = false),
      onSuccess: (list) {
        setState(() {
          _templates = list;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _createNewTemplate() async {
    final TextEditingController titleCtrl = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Novo Modelo de Processo'),
          content: TextField(
            controller: titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título do Modelo *',
              hintText: 'Ex: Fechamento Semanal, Mala de Viagem',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && titleCtrl.text.trim().isNotEmpty) {
      await ref.read(painelRepositoryProvider).createChecklist(<String, dynamic>{
        'titulo': titleCtrl.text.trim(),
        'ehModelo': true,
      });
      _loadTemplates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelos de Processos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTemplate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Modelo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const EmptyStateView(
                  icon: Icons.checklist_rounded,
                  title: 'Nenhum Modelo Criado',
                  description:
                      'Crie checklists reutilizáveis para rotinas como "Mala de viagem" ou "Revisão de sprint" e importe com 1 clique nas suas tarefas.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final tpl = _templates[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.copy_rounded,
                                      color: AppColors.primaryBrand,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      tpl.titulo,
                                      style: AppTypography.cardTitle,
                                    ),
                                  ],
                                ),
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
                                    '${tpl.totalItens} itens',
                                    style: AppTypography.chipLabel.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (tpl.itens.isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppSpacing.xs),
                              ...tpl.itens.take(3).map(
                                    (it) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                      child: Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.fiber_manual_record,
                                            size: 8,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            it.descricao,
                                            style: AppTypography.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              if (tpl.itens.length > 3)
                                Text(
                                  '+ ${tpl.itens.length - 3} outros itens...',
                                  style: AppTypography.chipLabel.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
