import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Floating Action Button inteligente que reflete o estado de fadiga mental (RN02 / RF18).
///
/// Quando a ocupação ultrapassa 80% das horas úteis (`novosAgendamentosBloqueados == true`),
/// assume aparência acinzentada com ícone de cadeado e abre o [FatigueBlockedSheet] para remanejamento.
class SmartScheduleFab extends StatelessWidget {
  const SmartScheduleFab({
    required this.novosAgendamentosBloqueados,
    required this.onNovaAtividade,
    required this.onBloqueadoTap,
    super.key,
  });

  final bool novosAgendamentosBloqueados;
  final VoidCallback onNovaAtividade;
  final VoidCallback onBloqueadoTap;

  @override
  Widget build(BuildContext context) {
    if (novosAgendamentosBloqueados) {
      return FloatingActionButton.extended(
        key: const Key('nova_atividade_fab_bloqueado'),
        onPressed: onBloqueadoTap,
        backgroundColor: AppColors.borderSubtle, // #E2E8F0
        foregroundColor: AppColors.textSecondary, // #64748B
        elevation: 1,
        icon: const Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        label: Text(
          'Bloqueado (Fadiga)',
          style: AppTypography.chipLabel.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return FloatingActionButton.extended(
      key: const Key('nova_atividade_fab'),
      onPressed: onNovaAtividade,
      backgroundColor: AppColors.primaryBrand,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Nova Atividade',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
