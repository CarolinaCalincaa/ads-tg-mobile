import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/features/fechamento/data/repositories/fechamento_repository_impl.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/screens/fechamento_history_screen.dart';
import 'package:produtividade_tcc/features/fechamento/presentation/widgets/fechamento_detail_sheet.dart';

import '../../helpers/fake_fechamento_repository.dart';

void main() {
  group('FechamentoHistoryScreen Widget Tests (RF23 / E06-T03)', () {
    late FakeFechamentoRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeFechamentoRepository(
        historicoMock: <FechamentoEntity>[
          FechamentoEntity(
            id: 'fechamento-1',
            tipoCiclo: 'SEMANAL',
            dataInicio: '2026-10-06',
            dataFim: '2026-10-12',
            rotuloPeriodo: '06 — 12 de outubro',
            dataFechamento: DateTime.parse('2026-10-12T20:00:00Z'),
            metricas: const FechamentoMetricas(
              consistenciaPercentual: 74,
              habitosConcluidos: 18,
              habitosEsperados: 24,
              diasAtivos: 6,
              totalDiasCiclo: 7,
              sequenciaAtualDias: 5,
            ),
            acaoFuncionouBem: 'Ritual matinal sem telas',
            oqueFazerDiferente: 'Evitar reuniões na sexta',
            vitoriaReconhecer: 'Cumpri todos os treinos',
            fracassoAceitar: 'Dormi tarde na terça',
            insightIa: 'Excelente foco no pilar Movimento esta semana.',
          ),
          FechamentoEntity(
            id: 'fechamento-2',
            tipoCiclo: 'MENSAL',
            dataInicio: '2026-09-01',
            dataFim: '2026-09-30',
            rotuloPeriodo: 'Setembro / 2026',
            dataFechamento: DateTime.parse('2026-09-30T21:00:00Z'),
            metricas: const FechamentoMetricas(
              consistenciaPercentual: 81,
              habitosConcluidos: 75,
              habitosEsperados: 90,
              diasAtivos: 26,
              totalDiasCiclo: 30,
              sequenciaAtualDias: 12,
            ),
            acaoFuncionouBem: 'Revisão diária de 5 minutos',
          ),
        ],
      );
    });

    testWidgets(
      'renderiza lista do histórico e filtros de ciclo',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: FechamentoHistoryScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Título e Filtros
        expect(find.text('Histórico de Fechamentos'), findsOneWidget);
        expect(find.byKey(const Key('filter_todos')), findsOneWidget);
        expect(find.byKey(const Key('filter_semanal')), findsOneWidget);
        expect(find.byKey(const Key('filter_mensal')), findsOneWidget);

        // 2. Dois cards renderizados
        expect(find.text('06 — 12 de outubro'), findsOneWidget);
        expect(find.text('74%'), findsOneWidget);
        expect(find.text('Setembro / 2026'), findsOneWidget);
        expect(find.text('81%'), findsOneWidget);
      },
    );

    testWidgets(
      'toca em um card e abre FechamentoDetailSheet com dados consolidados',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fechamentoRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: FechamentoHistoryScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Toca no card semanal
        await tester.tap(find.byKey(const Key('history_card_fechamento-1')));
        await tester.pumpAndSettle();

        // Modal aberto com detalhes
        expect(find.byType(FechamentoDetailSheet), findsOneWidget);
        expect(find.text('Fechamento Semanal'), findsOneWidget);
        expect(find.text('74% consistência'), findsOneWidget);
        expect(find.text('Evitar reuniões na sexta'), findsOneWidget);
        expect(find.text('Cumpri todos os treinos'), findsOneWidget);
        // Rola a ListView interna do modal para garantir visibilidade dos blocos inferiores
        final Finder sheetListFinder = find.descendant(
          of: find.byType(FechamentoDetailSheet),
          matching: find.byType(ListView),
        );
        await tester.drag(sheetListFinder, const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(find.text('Dormi tarde na terça'), findsOneWidget);
        expect(find.text('Insight da IA'), findsOneWidget);
        expect(
          find.text('Excelente foco no pilar Movimento esta semana.'),
          findsOneWidget,
        );
      },
    );
  });
}
