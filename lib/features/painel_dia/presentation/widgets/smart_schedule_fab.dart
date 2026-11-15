import 'package:flutter/material.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';

/// Floating Action Buttons inteligentes que refletem o estado de fadiga mental (RN02 / RF18)
/// e dão acesso direto lado a lado para **Novo Hábito** e **Nova Atividade**.
///
/// Quando a ocupação ultrapassa 80% das horas úteis (`novosAgendamentosBloqueados == true`),
/// o botão de agendamento assume aparência acinzentada com ícone de cadeado e abre o
/// [FatigueBlockedSheet] para remanejamento.
class SmartScheduleFab extends StatelessWidget {
  const SmartScheduleFab({
    required this.novosAgendamentosBloqueados,
    required this.onNovaAtividade,
    required this.onBloqueadoTap,
    this.onNovoHabito,
    super.key,
  });

  final bool novosAgendamentosBloqueados;
  final VoidCallback onNovaAtividade;
  final VoidCallback? onNovoHabito;
  final VoidCallback onBloqueadoTap;

  @override
  Widget build(BuildContext context) {
    if (novosAgendamentosBloqueados) {
      return FloatingActionButton.extended(
        key: const Key('nova_atividade_fab_bloqueado'),
        heroTag: 'nova_atividade_fab_bloqueado_hero',
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

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (onNovoHabito != null) ...<Widget>[
              FloatingActionButton.extended(
                key: const Key('novo_habito_fab'),
                heroTag: 'novo_habito_fab_hero',
                onPressed: onNovoHabito,
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                elevation: 3,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
                icon: const Icon(Icons.repeat_rounded, size: 18),
                label: const Text(
                  'Novo Hábito',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            FloatingActionButton.extended(
              key: const Key('nova_atividade_fab'),
              heroTag: 'nova_atividade_fab_hero',
              onPressed: onNovaAtividade,
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: Colors.white,
              elevation: 3,
              extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Nova Atividade',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
