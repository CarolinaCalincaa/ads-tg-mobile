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

  testWidgets('ProdutividadeTccApp renders initial Painel tab when authenticated', (
    WidgetTester tester,
  ) async {
    const UsuarioEntity testUser = UsuarioEntity(
      id: 'test-user-id',
      nomeCompleto: 'Carolina Calinca',
      email: 'carolina@fatec.sp.gov.br',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => AuthNotifier(
              initialState: const AuthState.authenticated(testUser),
            ),
          ),
        ],
        child: const ProdutividadeTccApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Painel do Dia'), findsOneWidget);
    expect(find.text('Seu Painel do Dia está pronto'), findsOneWidget);
  });
}
