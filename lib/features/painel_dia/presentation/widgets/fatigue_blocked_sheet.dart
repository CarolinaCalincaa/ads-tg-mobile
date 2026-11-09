import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/painel_dia/data/repositories/painel_repository_impl.dart';

/// Modal exibido quando o usuário tenta agendar atividades em uma data com fadiga mental ativa (RN02 / RF18).
///
/// Apresenta a mensagem canônica de bloqueio e oferece 3 caminhos de alívio cognitivo:
/// 1. Chips de 1 toque para os 3 dias mais livres da semana;
/// 2. Registro como pendência Em Espera (não impacta carga do dia);
/// 3. Remanejamento das tarefas já agendadas hoje.
class FatigueBlockedSheet extends ConsumerStatefulWidget {
  const FatigueBlockedSheet({
    required this.dataAtual,
    super.key,
    this.onAgendarEmDataLivre,
    this.onRegistrarEmEspera,
    this.onDesafogarHoje,
  });

  final String dataAtual;
  final ValueChanged<String>? onAgendarEmDataLivre;
  final VoidCallback? onRegistrarEmEspera;
  final VoidCallback? onDesafogarHoje;

  @override
  ConsumerState<FatigueBlockedSheet> createState() =>
      _FatigueBlockedSheetState();
}

class _FatigueBlockedSheetState extends ConsumerState<FatigueBlockedSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _diasLivres = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _carregarDiasLivres();
  }

  Future<void> _carregarDiasLivres() async {
    final result = await ref.read(painelRepositoryProvider).getDiasLivres(
          dataOrigem: widget.dataAtual,
          duracaoMinutos: 60,
        );
    if (!mounted) return;

    result.fold(
      onFailure: (_) => setState(() => _isLoading = false),
      onSuccess: (dias) {
        setState(() {
          _diasLivres = dias;
          _isLoading = false;
        });
      },
    );
  }

  String _formatarDataChip(String dataYmd) {
    try {
      final parts = dataYmd.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}';
      }
    } catch (_) {}
    return dataYmd;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Indicador de arraste
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Card Canônico de Bloqueio por Fadiga Mental (RN02)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.fatigueBg, // #FEF2F2
                borderRadius: AppSpacing.cardRadius,
                border: Border.all(
                  color: AppColors.fatigueBorder, // #FECACA
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_clock_rounded,
                        color: AppColors.fatigueCritical,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Limite de horas atingido, reagende a atividade.',
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.fatigueCritical,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sua carga horária para hoje ultrapassou 80% das horas úteis planejadas. Para evitar sobrecarga mental (RN02), novos agendamentos diretos nesta data estão bloqueados.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Seção 1: Dias Livres Sugeridos
            Text(
              'Sugestões de Dias Livres',
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Toque em um dia com capacidade disponível para agendar:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_diasLivres.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppSpacing.cardRadius,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Sem sugestões automáticas nos próximos 7 dias.',
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _diasLivres.take(3).map((dia) {
                  final String dataStr =
                      (dia['data'] ?? dia['dataYmd'] ?? '').toString();
                  final int pct = (dia['percentualOcupacao'] as num?)?.toInt() ??
                      (dia['ocupacao'] as num?)?.toInt() ??
                      0;
                  final String chipLabel =
                      '📅 ${_formatarDataChip(dataStr)} ($pct% ocupado)';

                  return ActionChip(
                    key: Key('chip_dia_livre_$dataStr'),
                    avatar: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.capacityHealthy,
                    ),
                    label: Text(chipLabel),
                    backgroundColor: AppColors.surfaceSubtle,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    labelStyle: AppTypography.chipLabel.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onAgendarEmDataLivre?.call(dataStr);
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),

            // Seção 2: Ações de Desafogo Cognitivo
            // Botão Secundário: Registrar como pendência Em Espera
            OutlinedButton.icon(
              key: const Key('registrar_em_espera_btn'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRegistrarEmEsperarSafe();
              },
              icon: const Icon(Icons.hourglass_empty_rounded, size: 18),
              label: const Text('Registrar como pendência Em Espera'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.cardRadius,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Botão Terciário: Desafogar Hoje (Remanejar tarefas existentes)
            TextButton.icon(
              key: const Key('desafogar_hoje_btn'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDesafogarHoje?.call();
              },
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Desafogar Hoje (Remanejar tarefas existentes)'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBrand,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on FatigueBlockedSheet {
  void onRegistrarEmEsperarSafe() {
    onRegistrarEmEspera?.call();
  }
}
