import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/features/rotina/data/repositories/rotina_repository_impl.dart';
import 'package:produtividade_tcc/features/rotina/presentation/screens/rotina_screen.dart';

import '../../helpers/fake_rotina_repository.dart';

void main() {
  group('RotinaScreen (Centro de Controle da Rotina)', () {
    late FakeRotinaRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeRotinaRepository();
    });

    testWidgets(
      'renderiza KPIs, alterna entre Tarefas, Hábitos e Em Espera e permite concluir tarefa',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rotinaRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(
              home: RotinaScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verifica título e presença dos 4 KPIs
        expect(find.text('Centro de Controle da Rotina'), findsOneWidget);
        expect(find.byKey(const Key('rotina_kpi_pendentes')), findsOneWidget);
        expect(find.byKey(const Key('rotina_kpi_concluidas')), findsOneWidget);
        expect(find.byKey(const Key('rotina_kpi_habitos')), findsOneWidget);
        expect(find.byKey(const Key('rotina_kpi_streak')), findsOneWidget);

        // 2. Segmento inicial: Tarefas (Minhas Ações)
        expect(find.text('Redigir Capítulo de Resultados'), findsOneWidget);
        expect(find.text('Aguardando Parecer da Banca'), findsNothing);

        // Conclui a tarefa com 1 clique otimista
        await tester.tap(find.byKey(const Key('rotina_task_checkbox_t1')));
        await tester.pumpAndSettle();
        expect(fakeRepo.tarefas.first.concluido, isTrue);

        // 3. Alterna para o segmento Hábitos
        await tester.tap(find.textContaining('Hábitos ('));
        await tester.pumpAndSettle();
        expect(find.text('Beber 2.5L de Água'), findsOneWidget);
        expect(find.text('9d'), findsOneWidget);

        // 4. Alterna para o segmento Em Espera
        await tester.tap(find.textContaining('Em Espera ('));
        await tester.pumpAndSettle();
        expect(find.text('Aguardando Parecer da Banca'), findsOneWidget);
      },
    );
  });
}
