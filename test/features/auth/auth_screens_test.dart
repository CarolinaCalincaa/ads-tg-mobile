import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/app.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';
import 'package:produtividade_tcc/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:produtividade_tcc/features/auth/data/models/usuario_model.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/register_screen.dart';
import 'package:produtividade_tcc/features/auth/presentation/widgets/password_strength_checklist.dart';

class _TestAuthRemoteDataSource implements AuthRemoteDataSource {
  bool registerCalled = false;
  bool loginCalled = false;
  bool googleCalled = false;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  }) async {
    loginCalled = true;
    return AuthSessionModel(
      usuario: UsuarioModel(
        id: 'u-1',
        nomeCompleto: 'Carolina Calinca',
        email: email,
      ),
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );
  }

  @override
  Future<AuthSessionModel> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) async {
    registerCalled = true;
    return AuthSessionModel(
      usuario: UsuarioModel(
        id: 'u-2',
        nomeCompleto: nomeCompleto,
        email: email,
        horasSonoDiarias: horasSonoDiarias,
      ),
      accessToken: 'access-2',
      refreshToken: 'refresh-2',
    );
  }

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) async {
    googleCalled = true;
    return const AuthSessionModel(
      usuario: UsuarioModel(
        id: 'u-google',
        nomeCompleto: 'Carolina Google',
        email: 'carolina.google@fatec.sp.gov.br',
        provedorOauth: ProvedorOAuth.google,
      ),
      accessToken: 'access-g',
      refreshToken: 'refresh-g',
    );
  }

  @override
  Future<AuthSessionModel> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  }) async {
    return const AuthSessionModel(
      usuario: UsuarioModel(
        id: 'u-apple',
        nomeCompleto: 'Carolina Apple',
        email: 'carolina.apple@fatec.sp.gov.br',
        provedorOauth: ProvedorOAuth.apple,
      ),
      accessToken: 'access-a',
      refreshToken: 'refresh-a',
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {}

  @override
  Future<UsuarioModel> getMe() async {
    return const UsuarioModel(
      id: 'u-1',
      nomeCompleto: 'Carolina Calinca',
      email: 'carolina@fatec.sp.gov.br',
    );
  }

  @override
  Future<UsuarioModel> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    return UsuarioModel(
      id: 'u-1',
      nomeCompleto: nomeCompleto ?? 'Carolina Calinca',
      email: 'carolina@fatec.sp.gov.br',
      horasSonoDiarias: horasSonoDiarias ?? 8,
    );
  }

  @override
  Future<void> deleteAccount({String confirmacao = 'EXCLUIR'}) async {}

  @override
  Future<void> logout({required String refreshToken}) async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LoginScreen & RegisterScreen Widget Tests (E02-T04)', () {
    testWidgets(
      'unauthenticated user is redirected to LoginScreen and can sign in to reach Painel',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _TestAuthRemoteDataSource remote = _TestAuthRemoteDataSource();
        final InMemoryTokenStorage storage = InMemoryTokenStorage();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRemoteDataSourceProvider.overrideWithValue(remote),
              secureTokenStorageProvider.overrideWithValue(storage),
            ],
            child: const ProdutividadeTccApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Guard must redirect to /login
        expect(find.text('Entrar na sua conta'), findsOneWidget);
        expect(find.text('Continuar com Google'), findsOneWidget);
        expect(find.text('Continuar com Apple'), findsOneWidget);

        // Submit empty form -> validation errors
        final Finder submitFinder = find.byKey(const Key('login_submit_button'));
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();
        expect(find.text('Informe seu e-mail.'), findsOneWidget);
        expect(find.text('Informe sua senha.'), findsOneWidget);

        // Fill valid credentials and sign in
        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'carolina@fatec.sp.gov.br',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'Fatec@2026',
        );
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(remote.loginCalled, isTrue);
        expect(find.text('Painel do Dia'), findsOneWidget);
      },
    );

    testWidgets(
      'RegisterScreen updates PasswordStrengthChecklist in real-time and blocks weak passwords (RF02)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _TestAuthRemoteDataSource remote = _TestAuthRemoteDataSource();
        final InMemoryTokenStorage storage = InMemoryTokenStorage();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRemoteDataSourceProvider.overrideWithValue(remote),
              secureTokenStorageProvider.overrideWithValue(storage),
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.unauthenticated(),
                ),
              ),
            ],
            child: const MaterialApp(
              home: RegisterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PasswordStrengthChecklist), findsOneWidget);
        expect(find.text('0/5 critérios'), findsOneWidget);

        // Fill name and email, weak password
        await tester.enterText(
          find.byKey(const Key('register_name_field')),
          'Carolina Calinca',
        );
        await tester.enterText(
          find.byKey(const Key('register_email_field')),
          'carolina@fatec.sp.gov.br',
        );
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'fraca',
        );
        await tester.pump();

        expect(find.text('1/5 critérios'), findsOneWidget);

        // Try to submit with weak password and unchecked LGPD
        final Finder submitFinder = find.byKey(
          const Key('register_submit_button'),
        );
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'A senha deve atender a todos os 5 critérios de segurança (RF02).',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Confirme o consentimento LGPD para criar sua conta.'),
          findsOneWidget,
        );
        expect(remote.registerCalled, isFalse);

        // Enter strong password meeting all 5 criteria
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'Fatec@2026',
        );
        await tester.pump();
        expect(find.text('5/5 critérios'), findsOneWidget);

        // Check LGPD consent and submit
        final Finder lgpdFinder = find.byKey(const Key('register_lgpd_checkbox'));
        await tester.ensureVisible(lgpdFinder);
        await tester.tap(lgpdFinder);
        await tester.pump();
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        expect(remote.registerCalled, isTrue);
      },
    );
  });
}
