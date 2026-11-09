import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:produtividade_tcc/core/theme/app_colors.dart';
import 'package:produtividade_tcc/core/theme/app_spacing.dart';
import 'package:produtividade_tcc/core/theme/app_typography.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/providers/fechamento_notifier.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/cycle_metric_summary_row.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/guided_reflection_card.dart';

class FechamentoScreen extends ConsumerStatefulWidget {
  const FechamentoScreen({
    super.key,
    this.initialTipoCiclo = 'SEMANAL',
    this.initialDataRef,
  });

  final String initialTipoCiclo;
  final String? initialDataRef;

  @override
  ConsumerState<FechamentoScreen> createState() => _FechamentoScreenState();
}

class _FechamentoScreenState extends ConsumerState<FechamentoScreen> {
  final TextEditingController _acaoBemController = TextEditingController();
  final TextEditingController _oqueDiferenteController =
      TextEditingController();
  final TextEditingController _vitoriaController = TextEditingController();
  final TextEditingController _fracassoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fechamentoNotifierProvider.notifier).carregarPrevia(
            tipoCiclo: widget.initialTipoCiclo,
            dataRef: widget.initialDataRef,
          );
    });
  }

  @override
  void dispose() {
    _acaoBemController.dispose();
    _oqueDiferenteController.dispose();
    _vitoriaController.dispose();
    _fracassoController.dispose();
    super.dispose();
  }

  void _sincronizarTextos(FechamentoPrevia previa) {
    if (_acaoBemController.text.isEmpty && previa.acaoFuncionouBem != null) {
      _acaoBemController.text = previa.acaoFuncionouBem!;
    }
    if (_oqueDiferenteController.text.isEmpty &&
        previa.oqueFazerDiferente != null) {
      _oqueDiferenteController.text = previa.oqueFazerDiferente!;
    }
    if (_vitoriaController.text.isEmpty && previa.vitoriaReconhecer != null) {
      _vitoriaController.text = previa.vitoriaReconhecer!;
    }
    if (_fracassoController.text.isEmpty && previa.fracassoAceitar != null) {
      _fracassoController.text = previa.fracassoAceitar!;
    }
  }

  Future<void> _submeterFechamento() async {
    final bool ok =
        await ref.read(fechamentoNotifierProvider.notifier).salvarFechamento(
              acaoFuncionouBem: _acaoBemController.text.trim(),
              oqueFazerDiferente: _oqueDiferenteController.text.trim(),
              vitoriaReconhecer: _vitoriaController.text.trim(),
              fracassoAceitar: _fracassoController.text.trim(),
            );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fechamento reflexivo salvo com sucesso!'),
          backgroundColor: AppColors.capacityHealthy,
        ),
      );
    } else {
      final String? err = ref.read(fechamentoNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Erro ao salvar fechamento.'),
          backgroundColor: AppColors.fatigueCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FechamentoState state = ref.watch(fechamentoNotifierProvider);

    if (state.previa != null) {
      _sincronizarTextos(state.previa!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechamento Reflexivo'),
        actions: <Widget>[
          IconButton(
            key: const Key('btn_historico_fechamentos'),
            tooltip: 'Histórico de Fechamentos',
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              context.push('/fechamento/historico');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.status == FechamentoStatus.loading && state.previa == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(fechamentoNotifierProvider.notifier)
                      .carregarPrevia();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 1. Seletor Semanal / Mensal
                      Center(
                        child: SegmentedButton<String>(
                          segments: const <ButtonSegment<String>>[
                            ButtonSegment<String>(
                              value: 'SEMANAL',
                              label: Text('Semanal'),
                              icon: Icon(Icons.view_week_outlined),
                            ),
                            ButtonSegment<String>(
                              value: 'MENSAL',
                              label: Text('Mensal'),
                              icon: Icon(Icons.calendar_month_outlined),
                            ),
                          ],
                          selected: <String>{state.tipoCiclo},
                          onSelectionChanged: (Set<String> novo) {
                            if (novo.isNotEmpty) {
                              ref
                                  .read(fechamentoNotifierProvider.notifier)
                                  .alternarTipoCiclo(novo.first);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 2. Header de Consistência e Período (Mockup 02)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    state.tipoCiclo == 'SEMANAL'
                                        ? 'Ciclo Semanal'
                                        : 'Ciclo Mensal',
                                    style: AppTypography.chipLabel.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.previa?.rotuloPeriodo.isNotEmpty ==
                                            true
                                        ? state.previa!.rotuloPeriodo
                                        : 'Período do Ciclo',
                                    style: AppTypography.cardTitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.capacityHealthy
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.capacityHealthy
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Consistência',
                                    style: AppTypography.chipLabel.copyWith(
                                      color: AppColors.capacityHealthy,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${state.previa?.metricas.consistenciaPercentual ?? 0}%',
                                    style: AppTypography.displayTitle.copyWith(
                                      color: AppColors.capacityHealthy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 3. MetricCards (Hábitos, Dias ativos, Sequência)
                      CycleMetricSummaryRow(
                        metricas: state.previa?.metricas ??
                            const FechamentoMetricas(
                              consistenciaPercentual: 0,
                              habitosConcluidos: 0,
                              habitosEsperados: 0,
                              diasAtivos: 0,
                              totalDiasCiclo: 7,
                              sequenciaAtualDias: 0,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 4. Seção REFLEXÃO GUIADA
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.psychology_outlined,
                            size: 18,
                            color: AppColors.primaryBrand,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'REFLEXÃO GUIADA',
                            style: AppTypography.chipLabel.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Card 1: ⭐ Ação que funcionou bem
                      GuidedReflectionCard(
                        emoji: '⭐',
                        title: 'Ação que funcionou bem',
                        subtitle:
                            'O que facilitou sua consistência nesta semana/mês?',
                        hintText:
                            'Ex: Fazer o ritual sem telas logo ao acordar...',
                        controller: _acaoBemController,
                        accentColor: AppColors.capacityHealthy,
                      ),

                      // Card 2: 📈 O que farei diferente
                      GuidedReflectionCard(
                        emoji: '📈',
                        title: 'O que farei diferente',
                        subtitle:
                            'Qual ajuste pequeno pode evitar gargalos no próximo ciclo?',
                        hintText:
                            'Ex: Planejar as 3 prioridades do dia na noite anterior...',
                        controller: _oqueDiferenteController,
                        accentColor: AppColors.primaryBrand,
                      ),

                      // Card 3: 🏅 Vitória a reconhecer
                      GuidedReflectionCard(
                        emoji: '🏅',
                        title: 'Vitória a reconhecer',
                        subtitle:
                            'Celebre qualquer avanço, mesmo que pareça pequeno.',
                        hintText:
                            'Ex: Consegui manter a sequência de atividade física por 5 dias!',
                        controller: _vitoriaController,
                        accentColor: AppColors.pilarFinancas,
                      ),

                      // Card 4: 🎯 Fracasso a aceitar
                      GuidedReflectionCard(
                        emoji: '🎯',
                        title: 'Fracasso a aceitar',
                        subtitle:
                            'Sem culpa: o que não saiu como esperado e precisa de acolhimento?',
                        hintText:
                            'Ex: Não consegui ler todos os dias, mas vou calibrar a meta.',
                        controller: _fracassoController,
                        accentColor: AppColors.accentViolet,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 5. Botão "Finalizar Fechamento"
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x336366F1),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          key: const Key('btn_finalizar_fechamento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              state.isLoading ? null : _submeterFechamento,
                          child: state.status == FechamentoStatus.saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '✓ Finalizar Fechamento',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
