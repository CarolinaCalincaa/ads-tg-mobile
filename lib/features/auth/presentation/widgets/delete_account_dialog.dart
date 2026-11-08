import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Diálogo de confirmação explícita para Exclusão Definitiva de Conta e Dados (LGPD — `RNF07`, `E02-T05`).
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    required this.onConfirmDelete,
    super.key,
  });

  final Future<void> Function() onConfirmDelete;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _confirmedIrreversible = false;
  bool _isDeleting = false;

  Future<void> _handleConfirm() async {
    if (!_confirmedIrreversible || _isDeleting) {
      return;
    }
    setState(() {
      _isDeleting = true;
    });
    await widget.onConfirmDelete();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.cardRadius,
      ),
      title: Row(
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.fatigueCritical,
            size: 26,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Excluir conta permanentemente?',
              style: AppTypography.cardTitle.copyWith(
                color: AppColors.fatigueCritical,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Em conformidade com a LGPD (RNF07 — Direito ao Esquecimento), esta ação apagará imediatamente e em cascata todos os seus dados:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '• Perfil, sessões ativas e configurações de sono\n'
              '• Pilares mensais, tarefas, compromissos e projetos\n'
              '• Hábitos, sequências (streaks) e modelos de checklists\n'
              '• Sessões Pomodoro e histórico de fechamentos reflexivos',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              key: const Key('delete_account_confirm_checkbox'),
              borderRadius: AppSpacing.inputRadius,
              onTap: _isDeleting
                  ? null
                  : () {
                      setState(() {
                        _confirmedIrreversible = !_confirmedIrreversible;
                      });
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      value: _confirmedIrreversible,
                      activeColor: AppColors.fatigueCritical,
                      onChanged: _isDeleting
                          ? null
                          : (bool? value) {
                              setState(() {
                                _confirmedIrreversible = value ?? false;
                              });
                            },
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Estou ciente de que esta exclusão é definitiva e não poderá ser desfeita.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('delete_account_cancel_button'),
          onPressed: _isDeleting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton.icon(
          key: const Key('delete_account_confirm_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.fatigueCritical,
            foregroundColor: AppColors.surfaceCard,
            disabledBackgroundColor: AppColors.borderSubtle,
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.inputRadius,
            ),
          ),
          onPressed: _confirmedIrreversible && !_isDeleting
              ? _handleConfirm
              : null,
          icon: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.surfaceCard,
                    ),
                  ),
                )
              : const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text('Excluir definitivamente'),
        ),
      ],
    );
  }
}
