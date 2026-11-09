import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/features/fechamento/data/repositories/fechamento_repository_impl.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/screens/fechamento_screen.dart';

import '../../helpers/fake_fechamento_repository.dart';

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
