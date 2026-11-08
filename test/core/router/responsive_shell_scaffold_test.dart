import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/app.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const UsuarioEntity authenticatedTestUser = UsuarioEntity(
    id: 'test-user-1',
    nomeCompleto: 'Carolina Calinca',
    email: 'carolina@fatec.sp.gov.br',
    horasSonoDiarias: 8,
  );

  group('ResponsiveShellScaffold & GoRouter 4-Tab Navigation (E01-T05)', () {
    testWidgets(
      'displays bottom NavigationBar on mobile viewport (390px) and navigates across 4 tabs',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.authenticated(
                    authenticatedTestUser,
                  ),
                ),
              ),
            ],
            child: const ProdutividadeTccApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Mobile (< 768px) must show NavigationBar and not NavigationRail
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // Initial tab 0: Painel
        expect(find.text('Seu Painel do Dia está pronto'), findsOneWidget);

        // Navigate to Tab 1: Relatórios
        await tester.tap(find.text('Relatórios'));
        await tester.pumpAndSettle();
        expect(find.text('Evolução & Fechamento Reflexivo'), findsOneWidget);

        // Navigate to Tab 2: Alertas
        await tester.tap(find.text('Alertas'));
        await tester.pumpAndSettle();
        expect(find.text('Lembretes de Saúde Cognitiva'), findsOneWidget);

        // Navigate to Tab 3: Config.
        await tester.tap(find.text('Config.'));
        await tester.pumpAndSettle();
        expect(find.text('Configurações'), findsWidgets);

        // Navigate back to Tab 0: Painel
        await tester.tap(find.text('Painel'));
        await tester.pumpAndSettle();
        expect(find.text('Seu Painel do Dia está pronto'), findsOneWidget);
      },
    );

    testWidgets(
      'displays side NavigationRail on tablet/desktop viewport (1024px) and navigates across 4 tabs',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.authenticated(
                    authenticatedTestUser,
                  ),
                ),
              ),
            ],
            child: const ProdutividadeTccApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Tablet/Desktop (>= 768px) must show NavigationRail and not NavigationBar
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        // Initial tab 0: Painel
        expect(find.text('Seu Painel do Dia está pronto'), findsOneWidget);

        // Navigate to Relatórios via NavigationRail
        await tester.tap(find.text('Relatórios'));
        await tester.pumpAndSettle();
        expect(find.text('Evolução & Fechamento Reflexivo'), findsOneWidget);
      },
    );
  });
}
