import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  const ProjectFormDialog({super.key});

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int _selectedPilarId = 7; // Padrão: Carreira
  bool _isLoading = false;

  static const List<PilarResumoEntity> _pilaresPadrao = <PilarResumoEntity>[
    PilarResumoEntity(idPilar: 1, codigo: 'SAUDE', nome: 'Saúde', corHex: '#22C55E', corFundoHex: '#F0FDF4', icone: 'heart_pulse'),
    PilarResumoEntity(idPilar: 2, codigo: 'MOVIMENTO', nome: 'Movimento', corHex: '#F97316', corFundoHex: '#FFF7ED', icone: 'activity'),
    PilarResumoEntity(idPilar: 3, codigo: 'SONO', nome: 'Sono', corHex: '#6366F1', corFundoHex: '#EEF2FF', icone: 'moon'),
    PilarResumoEntity(idPilar: 4, codigo: 'EQUILIBRIO_MENTAL', nome: 'Equilíbrio', corHex: '#EC4899', corFundoHex: '#FDF2F8', icone: 'brain'),
    PilarResumoEntity(idPilar: 5, codigo: 'ESTUDOS', nome: 'Estudos', corHex: '#10B981', corFundoHex: '#ECFDF5', icone: 'book_open'),
    PilarResumoEntity(idPilar: 6, codigo: 'FINANCAS', nome: 'Finanças', corHex: '#EAB308', corFundoHex: '#FEFCE8', icone: 'wallet'),
    PilarResumoEntity(idPilar: 7, codigo: 'CARREIRA', nome: 'Carreira', corHex: '#0EA5E9', corFundoHex: '#F0F9FF', icone: 'briefcase'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String nome = _nameController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome do projeto.'),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref.read(painelRepositoryProvider).createProjeto(<String, dynamic>{
      'nome': nome,
      'idPilar': _selectedPilarId,
      if (_descController.text.trim().isNotEmpty)
        'descricao': _descController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.fatigueCritical,
          ),
        );
      },
      onSuccess: (ProjetoEntity projeto) {
        Navigator.of(context).pop(projeto);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Projeto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do Projeto *',
                hintText: 'Ex: TCC FATEC, Reforma da Casa',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Pilar Associado *', style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _pilaresPadrao.map((p) {
                final bool isSelected = p.idPilar == _selectedPilarId;
                return PilarChip(
                  nome: p.nome,
                  corHex: p.corHex,
                  corFundoHex: p.corFundoHex,
                  icone: p.icone,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedPilarId = p.idPilar;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Criar Projeto'),
        ),
      ],
    );
  }
}
