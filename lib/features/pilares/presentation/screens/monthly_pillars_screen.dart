import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/app_card.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/core/widgets/primary_gradient_button.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';
import 'package:produtividade_tcc/features/pilares/presentation/providers/pilares_notifier.dart';

/// Tela de Seleção dos 3 Pilares de Vida do Mês (`RF12`, `RN01` — `Mockup 01` e `ADR-006`).
///
/// Permite ao usuário escolher até 3 áreas prioritárias para direcionar seu foco cognitivo.
/// Bloqueia na UI e na API qualquer tentativa de ativar um 4º pilar, exibindo o alerta canônico:
/// `"Selecione apenas 3 pilares por mês!"`.
class MonthlyPillarsScreen extends ConsumerWidget {
  const MonthlyPillarsScreen({super.key});

  String _formatMesAno(String mesAno) {
    try {
      final DateTime date = DateTime.parse(mesAno);
      final DateFormat formatter = DateFormat("MMMM 'de' yyyy", 'pt_BR');
      final String formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (_) {
      return mesAno;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PilaresState state = ref.watch(pilaresNotifierProvider);
    final PilaresNotifier notifier = ref.read(pilaresNotifierProvider.notifier);

    // Escuta avisos de validação RN01 para exibir SnackBar
    ref.listen<PilaresState>(pilaresNotifierProvider, (previous, next) {
      if (next.hasWarning && previous?.warningMessage != next.warningMessage) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('warning_max_pillars_snackbar'),
            content: Row(
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    next.warningMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.fatigueCritical,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final int activeCount = state.activePillarIds.length;
    final bool isMaxReached = activeCount >= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilares do Mês (RN01)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              GoRouter.maybeOf(context)?.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Banner de Alerta RN01 no topo (quando aviso estiver ativo)
            if (state.hasWarning)
              Container(
                key: const Key('warning_max_pillars_banner'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                color: AppColors.fatigueBg,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.fatigueCritical,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        state.warningMessage!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.fatigueCritical,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: AppColors.fatigueCritical,
                      onPressed: notifier.clearWarning,
                    ),
                  ],
                ),
              ),

            // Cabeçalho com Contador Superior (N/3)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _formatMesAno(state.mesAno),
                            style: AppTypography.displayLarge.copyWith(fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          key: const Key('pilares_counter_badge'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isMaxReached
                                ? const Color(0xFFEEF2FF)
                                : AppColors.surfaceSubtle,
                            borderRadius: AppSpacing.chipRadius,
                            border: Border.all(
                              color: isMaxReached
                                  ? AppColors.primaryBrand
                                  : AppColors.borderSubtle,
                            ),
                          ),
                          child: Text(
                            'Pilares ativos no mês: $activeCount/3',
                            style: AppTypography.chipLabel.copyWith(
                              color: isMaxReached
                                  ? AppColors.primaryBrand
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Direcione sua atenção escolhendo até 3 pilares focais para este ciclo mensal (RN01).',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista dos 7 Pilares Mestres
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: state.pilaresMestres.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final PilarEntity pilar = state.pilaresMestres[index];
                  final bool isSelected =
                      state.activePillarIds.contains(pilar.id);
                  final Color pilarColor = AppColors.fromHex(pilar.corHex);
                  final Color pilarBgColor = AppColors.fromHex(
                    pilar.corFundoHex,
                    fallback: AppColors.surfaceSubtle,
                  );

                  return InkWell(
                    key: Key('pilar_card_${pilar.id}'),
                    onTap: () => notifier.togglePilar(pilar.id),
                    borderRadius: AppSpacing.cardRadius,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? pilarBgColor
                            : AppColors.surfaceCard,
                        borderRadius: AppSpacing.cardRadius,
                        border: Border.all(
                          color: isSelected
                              ? pilarColor
                              : AppColors.borderSubtle,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: pilarColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PilarChip.resolveIcon(pilar.icone),
                              color: pilarColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      pilar.nome,
                                      style: AppTypography.cardTitle.copyWith(
                                        color: isSelected
                                            ? pilarColor
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (isSelected) ...<Widget>[
                                      const SizedBox(width: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: pilarColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'ATIVO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pilar.descricao,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            key: Key('checkbox_pilar_${pilar.id}'),
                            value: isSelected,
                            activeColor: pilarColor,
                            onChanged: (_) => notifier.togglePilar(pilar.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botão Inferior de Salvar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PrimaryGradientButton(
                key: const Key('salvar_pilares_button'),
                label: 'Salvar Pilares do Mês',
                isLoading: state.isLoading,
                onPressed: () async {
                  final bool success = await notifier.salvar();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilares do mês salvos com sucesso!'),
                        backgroundColor: AppColors.primaryBrand,
                      ),
                    );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      GoRouter.maybeOf(context)?.pop();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
