import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/core/widgets/pilar_chip.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/presentation/providers/painel_dia_notifier.dart';

/// Barra horizontal com os 3 Pilares Focais do Mês (`RF12`, `RN01` — `Mockup 01`).
///
/// Exibe as pílulas dos pilares ativos (ex: `Movimento`, `Estudos`, `Carreira`).
/// - Tocar em um pilar filtra a Linha do Tempo por ele (toque repetido limpa o filtro).
/// - O botão `⚙️` abre a tela de seleção mensal [MonthlyPillarsScreen] (`/pilares-mensais`).
class ActivePillarsFilterRow extends ConsumerWidget {
  const ActivePillarsFilterRow({
    required this.pilaresAtivos,
    super.key,
  });

  final List<PilarResumoEntity> pilaresAtivos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? selectedFilter =
        ref.watch(painelDiaNotifierProvider).selectedPilarFilter;
    final PainelDiaNotifier notifier =
        ref.read(painelDiaNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  if (pilaresAtivos.isEmpty)
                    InkWell(
                      key: const Key('definir_pilares_chip'),
                      onTap: () => context.push(AppRoutes.pilaresMensais),
                      borderRadius: AppSpacing.chipRadius,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs + 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: AppSpacing.chipRadius,
                          border: Border.all(
                            color: AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Definir 3 Pilares do Mês',
                              style: AppTypography.chipLabel.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...<Widget>[
                    for (final PilarResumoEntity pilar in pilaresAtivos) ...<Widget>[
                      PilarChip(
                        key: Key('pilar_filter_chip_${pilar.idPilar}'),
                        nome: pilar.nome,
                        corHex: pilar.corHex,
                        corFundoHex: pilar.corFundoHex,
                        icone: pilar.icone,
                        isSelected: selectedFilter == pilar.idPilar,
                        onTap: () => notifier.togglePilarFilter(pilar.idPilar),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            key: const Key('config_pilares_button'),
            icon: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Configurar 3 Pilares do Mês (RN01)',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => context.push(AppRoutes.pilaresMensais),
          ),
        ],
      ),
    );
  }
}
