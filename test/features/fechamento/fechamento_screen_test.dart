import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/fechamento/data/repositories/fechamento_repository_impl.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/screens/fechamento_screen.dart';

import '../../helpers/fake_fechamento_repository.dart';

class _FailingPreviaRepository extends FakeFechamentoRepository {
  @override
  Future<Result<FechamentoPrevia>> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  }) async {
    return const FailureResult<FechamentoPrevia>(
      NetworkFailure(message: 'Sem conexão com a prévia'),
    );
  }
}

void main() {
  group('FechamentoScreen Widget Tests (Mockup 02 / RF22 / E06-T02)', () {
    late FakeFechamentoRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeFechamentoRepository(
        previaMock: const FechamentoPrevia(
          tipoCiclo: 'SEMANAL',
          dataInicio: '2026-10-06',
          dataFim: '2026-10-12',
          rotuloPeriodo: '06 — 12 de outubro',
          metricas: FechamentoMetricas(
            consistenciaPercentual: 74,
            habitosConcluidos: 18,
            habitosEsperados: 24,
            diasAtivos: 6,
            totalDiasCiclo: 7,
            sequenciaAtualDias: 5,
          ),
          acaoFuncionouBem: 'Ritual matinal sem telas',
        ),
      );
    });

    test(
      'FechamentoPrevia.fromJson faz parse do formato real do backend (dataInicioCiclo e fechamentoSalvo)',
      () {
        final Map<String, dynamic> backendJson = <String, dynamic>{
          'tipoCiclo': 'SEMANAL',
          'dataRef': '2026-10-16',
          'dataInicioCiclo': '2026-10-12',
          'dataFimCiclo': '2026-10-18',
          'totalDiasCiclo': 7,
          'habitosConcluidos': 18,
          'habitosEsperados': 24,
          'consistenciaPercentual': 75,
          'diasAtivos': 6,
          'sequenciaAtualDias': 5,
          'fechamentoSalvo': <String, dynamic>{
            'id': 'fechamento-xyz',
            'acaoFuncionouBem': 'Acordar cedo',
            'oqueFazerDiferente': 'Dormir 22h',
            'vitoriaReconhecer': 'Foco no TCC',
            'fracassoAceitar': 'Pouca água',
            'dataFechamento': '2026-10-18',
          },
        };

        final FechamentoPrevia previa = FechamentoPrevia.fromJson(backendJson);
        expect(previa.tipoCiclo, 'SEMANAL');
        expect(previa.dataInicio, '2026-10-12');
        expect(previa.dataFim, '2026-10-18');
        expect(previa.rotuloPeriodo, '12 — 18 de outubro');
        expect(previa.metricas.consistenciaPercentual, 75);
        expect(previa.metricas.habitosConcluidos, 18);
        expect(previa.metricas.habitosEsperados, 24);
        expect(previa.acaoFuncionouBem, 'Acordar cedo');
        expect(previa.oqueFazerDiferente, 'Dormir 22h');
        expect(previa.vitoriaReconhecer, 'Foco no TCC');
        expect(previa.fracassoAceitar, 'Pouca água');
        expect(previa.fechamentoExistenteId, 'fechamento-xyz');
      },
    );

    testWidgets(
      'renderiza Mockup 02: header 74%, 3 metric cards e 4 cards guiados',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: FechamentoScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Header com período e Consistência 74%
        expect(find.text('06 — 12 de outubro'), findsOneWidget);
        expect(find.text('74%'), findsOneWidget);
        expect(find.text('Consistência'), findsOneWidget);

        // 2. Três MetricCards
        expect(find.byKey(const Key('metric_card_habitos')), findsOneWidget);
        expect(find.text('18/24'), findsOneWidget);
        expect(find.text('Hábitos concluídos'), findsOneWidget);

        expect(find.byKey(const Key('metric_card_dias_ativos')), findsOneWidget);
        expect(find.text('6/7'), findsOneWidget);
        expect(find.text('Dias ativos'), findsOneWidget);

        expect(find.byKey(const Key('metric_card_streak')), findsOneWidget);
        expect(find.text('5 dias 🔥'), findsOneWidget);
        expect(find.text('Sequência atual'), findsOneWidget);

        // 3. Quatro cards de reflexão guiada (Mockup 02)
        expect(find.text('REFLEXÃO GUIADA'), findsOneWidget);
        expect(find.text('Ação que funcionou bem'), findsOneWidget);
        expect(find.text('O que farei diferente'), findsOneWidget);
        expect(find.text('Vitória a reconhecer'), findsOneWidget);
        expect(find.text('Fracasso a aceitar'), findsOneWidget);

        // 4. Botão Finalizar Fechamento
        expect(find.byKey(const Key('btn_finalizar_fechamento')), findsOneWidget);
        expect(find.text('✓ Finalizar Fechamento'), findsOneWidget);
      },
    );

    testWidgets(
      'preenche reflexões e submete fechamento com sucesso',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: FechamentoScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Insere texto no segundo card ("O que farei diferente")
        final Finder textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsNWidgets(4));

        await tester.enterText(
          textFieldFinder.at(1),
          'Definir as prioridades na noite anterior',
        );
        await tester.enterText(
          textFieldFinder.at(2),
          'Manter 6 dias ativos na semana',
        );
        await tester.enterText(
          textFieldFinder.at(3),
          'Aceitar imprevistos na quinta-feira',
        );

        // Rola até o botão e clica
        await tester.ensureVisible(find.byKey(const Key('btn_finalizar_fechamento')));
        await tester.tap(find.byKey(const Key('btn_finalizar_fechamento')));
        await tester.pumpAndSettle();

        // Valida que o repositório foi chamado com as respostas
        expect(fakeRepo.chamadasSalvar.length, 1);
        final Map<String, dynamic> chamada = fakeRepo.chamadasSalvar.first;
        expect(chamada['tipoCiclo'], 'SEMANAL');
        expect(chamada['oqueFazerDiferente'], 'Definir as prioridades na noite anterior');
        expect(chamada['vitoriaReconhecer'], 'Manter 6 dias ativos na semana');
        expect(chamada['fracassoAceitar'], 'Aceitar imprevistos na quinta-feira');

        // SnackBar de sucesso exibida
        expect(find.text('Fechamento reflexivo salvo com sucesso!'), findsOneWidget);
      },
    );

    testWidgets(
      'mesmo quando getPrevia falha, mantém prévia padrão calculada e permite salvar fechamento',
      (WidgetTester tester) async {
        final _FailingPreviaRepository failingRepo = _FailingPreviaRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(failingRepo),
            ],
            child: const MaterialApp(
              home: FechamentoScreen(
                initialTipoCiclo: 'SEMANAL',
                initialDataRef: '2026-10-15',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Mesmo com falha no getPrevia, exibe o rótulo do período calculado localmente e os cards
        expect(find.text('12 — 18 de outubro'), findsOneWidget);
        expect(find.byKey(const Key('metric_card_habitos')), findsOneWidget);

        final Finder textFieldFinder = find.byType(TextField);
        await tester.enterText(textFieldFinder.at(0), 'Mantive a calma');

        await tester.ensureVisible(find.byKey(const Key('btn_finalizar_fechamento')));
        await tester.tap(find.byKey(const Key('btn_finalizar_fechamento')));
        await tester.pumpAndSettle();

        expect(failingRepo.chamadasSalvar.length, 1);
        expect(failingRepo.chamadasSalvar.first['dataInicio'], '2026-10-12');
        expect(failingRepo.chamadasSalvar.first['acaoFuncionouBem'], 'Mantive a calma');
        expect(find.text('Fechamento reflexivo salvo com sucesso!'), findsOneWidget);
      },
    );

    testWidgets(
      'alterna seletor para Mensal e recarrega prévia',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: FechamentoScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Toca no segmento "Mensal"
        await tester.tap(find.text('Mensal'));
        await tester.pumpAndSettle();

        expect(find.text('Ciclo Mensal'), findsOneWidget);
      },
    );
  });
}
