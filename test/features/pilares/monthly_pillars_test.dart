import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';
import 'package:produtividade_tcc/features/pilares/data/repositories/pilares_repository_impl.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';
import 'package:produtividade_tcc/features/pilares/domain/repositories/pilares_repository.dart';
import 'package:produtividade_tcc/features/pilares/presentation/providers/pilares_notifier.dart';
import 'package:produtividade_tcc/features/pilares/presentation/screens/monthly_pillars_screen.dart';

class _FakePilaresRepository implements PilaresRepository {
  List<int> ativos = <int>[1, 2]; // 2 pilares ativos inicialmente (Saúde, Movimento)
  bool setPilaresAtivosCalled = false;
  List<int>? lastSavedIds;

  @override
  Future<Result<List<PilarEntity>>> getPilares() async {
    return const Success<List<PilarEntity>>(PilarEntity.pilaresMestresCanonicos);
  }

  @override
  Future<Result<List<int>>> getPilaresAtivos(String mesAno) async {
    return Success<List<int>>(ativos);
  }

  @override
  Future<Result<List<int>>> setPilaresAtivos(
    String mesAno,
    List<int> idsPilares,
  ) async {
    setPilaresAtivosCalled = true;
    lastSavedIds = idsPilares;
    if (idsPilares.length > 3) {
      return const FailureResult<List<int>>(
        MaxActivePillarsExceededFailure(
          message: 'Selecione apenas 3 pilares por mês!',
        ),
      );
    }
    ativos = idsPilares;
    return Success<List<int>>(idsPilares);
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MonthlyPillarsScreen & RN01 (Regra Crítica do TCC — E05-T03)', () {
    testWidgets(
      'exibe os 7 pilares mestres, contador N/3 e bloqueia o 4º pilar com alerta canônico',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(500, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _FakePilaresRepository fakeRepo = _FakePilaresRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              pilaresRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const MonthlyPillarsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verifica renderização inicial e contador 2/3
        expect(find.text('Pilares do Mês'), findsOneWidget);
        expect(find.text('Pilares ativos no mês: 2/3'), findsOneWidget);

        // Verifica presença de pilares do TCC
        expect(find.text('Saúde'), findsOneWidget);
        expect(find.text('Movimento'), findsOneWidget);
        expect(find.text('Sono'), findsOneWidget);
        expect(find.text('Mente'), findsOneWidget);
        expect(find.text('Estudos'), findsOneWidget);
        expect(find.text('Finanças'), findsOneWidget);
        expect(find.text('Carreira'), findsOneWidget);

        // 2. Seleciona o 3º pilar: Sono (id 3)
        await tester.tap(find.byKey(const Key('pilar_card_3')));
        await tester.pumpAndSettle();

        // Contador deve atualizar para 3/3
        expect(find.text('Pilares ativos no mês: 3/3'), findsOneWidget);

        // 3. Tenta selecionar o 4º pilar: Mente (id 4) -> VIOLAÇÃO RN01!
        await tester.tap(find.byKey(const Key('pilar_card_4')));
        await tester.pumpAndSettle();

        // Deve manter 3/3
        expect(find.text('Pilares ativos no mês: 3/3'), findsOneWidget);

        // DEVE exibir a mensagem canônica exata em banner ou SnackBar
        expect(find.text('Selecione apenas 3 pilares por mês!'), findsWidgets);
        expect(find.byKey(const Key('warning_max_pillars_banner')), findsOneWidget);

        // 4. Salva as alterações
        ScaffoldMessenger.of(
          tester.element(find.byType(MonthlyPillarsScreen)),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('salvar_pilares_button')));
        await tester.pumpAndSettle();

        expect(fakeRepo.setPilaresAtivosCalled, isTrue);
        expect(fakeRepo.lastSavedIds, containsAll(<int>[1, 2, 3]));
        expect(fakeRepo.lastSavedIds!.length, 3);
      },
    );

    test('PilaresNotifier valida RN01 e bloqueia 4º pilar em memória', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          pilaresRepositoryProvider.overrideWithValue(_FakePilaresRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pilaresNotifierProvider.notifier);
      await notifier.loadPilares('2026-10-01');

      // Inicia com 2 pilares (1 e 2)
      notifier.togglePilar(3); // ativa 3
      expect(container.read(pilaresNotifierProvider).activePillarIds.length, 3);
      expect(container.read(pilaresNotifierProvider).warningMessage, isNull);

      // Tenta 4º pilar (id 4)
      notifier.togglePilar(4);
      final state = container.read(pilaresNotifierProvider);
      expect(state.activePillarIds.length, 3);
      expect(state.activePillarIds.contains(4), isFalse);
      expect(state.warningMessage, 'Selecione apenas 3 pilares por mês!');

      // Desmarca o pilar 2
      notifier.togglePilar(2);
      expect(container.read(pilaresNotifierProvider).activePillarIds.length, 2);
      expect(container.read(pilaresNotifierProvider).warningMessage, isNull);
    });
  });
}
