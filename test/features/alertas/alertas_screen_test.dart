import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/notifications/local_notification_service.dart';
import 'package:produtividade_tcc/core/theme/app_theme.dart';
import 'package:produtividade_tcc/features/alertas/data/repositories/lembretes_repository_impl.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';
import 'package:produtividade_tcc/features/alertas/domain/repositories/lembretes_repository.dart';
import 'package:produtividade_tcc/features/alertas/presentation/screens/alertas_screen.dart';
import 'package:produtividade_tcc/core/error/result.dart';

class _FakeLembretesRepository implements LembretesRepository {
  List<LembreteConfigEntity> configs = List<LembreteConfigEntity>.from(
    LembreteConfigEntity.padroes,
  );
  bool saveCalled = false;

  @override
  Future<Result<List<LembreteConfigEntity>>> getLembretes() async {
    return Success<List<LembreteConfigEntity>>(configs);
  }

  @override
  Future<Result<List<LembreteConfigEntity>>> saveLembretes(
    List<LembreteConfigEntity> newConfigs,
  ) async {
    saveCalled = true;
    configs = newConfigs;
    return Success<List<LembreteConfigEntity>>(configs);
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AlertasScreen & LocalNotificationService (RF21 — E05-T05)', () {
    testWidgets(
      'renderiza os 4 cards de lembretes cognitivos e dispara alerta de teste',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(450, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _FakeLembretesRepository fakeRepo = _FakeLembretesRepository();
        final LocalNotificationService notificationService =
            LocalNotificationService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              lembretesRepositoryProvider.overrideWithValue(fakeRepo),
              localNotificationServiceProvider
                  .overrideWithValue(notificationService),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AlertasScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Verifica título da tela e cabeçalho explicativo
        expect(find.text('Alertas Saudáveis'), findsOneWidget);
        expect(find.text('Lembretes de Saúde Cognitiva'), findsOneWidget);

        // 2. Verifica a presença das 4 categorias canônicas
        expect(find.text('💧 Hidratação (Água)'), findsOneWidget);
        expect(find.text('🧘 Pausa & Alongamento'), findsOneWidget);
        expect(find.text('🌙 Ritual de Sono'), findsOneWidget);
        expect(find.text('📝 Fechamento Semanal'), findsOneWidget);

        // 3. Testa disparo de alerta de teste para Hidratação
        final Finder btnTestarAgua =
            find.byKey(const Key('test_reminder_agua'));
        expect(btnTestarAgua, findsOneWidget);

        await tester.tap(btnTestarAgua);
        await tester.pumpAndSettle();

        // Notificação de teste registrada no log do serviço
        expect(notificationService.testNotificationLog.length, 1);
        expect(
          notificationService.testNotificationLog.first['title'],
          '💧 Hidratação (Água)',
        );

        // SnackBar de confirmação visual exibido
        expect(
          find.text('Notificação de teste disparada: "💧 Hidratação (Água)"'),
          findsOneWidget,
        );

        // 4. Testa alteração de switch (desativa alongamento)
        final Finder switchAlongamento =
            find.byKey(const Key('switch_reminder_alongamento'));
        expect(switchAlongamento, findsOneWidget);

        await tester.tap(switchAlongamento);
        await tester.pumpAndSettle();

        expect(fakeRepo.saveCalled, isTrue);
      },
    );
  });
}
