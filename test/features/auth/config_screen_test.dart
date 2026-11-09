import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';
import 'package:produtividade_tcc/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:produtividade_tcc/features/auth/data/models/usuario_model.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';
import 'package:produtividade_tcc/features/auth/presentation/screens/config_screen.dart';

class _ConfigFakeRemoteDataSource implements AuthRemoteDataSource {
  int? updatedSleepHours;
  String? updatedName;
  bool deleteAccountCalled = false;

  UsuarioModel current = const UsuarioModel(
    id: 'user-config-1',
    nomeCompleto: 'Carolina Calinca',
    email: 'carolina@fatec.sp.gov.br',
    horasSonoDiarias: 8,
  );

  @override
  Future<UsuarioModel> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    updatedName = nomeCompleto ?? updatedName;
    updatedSleepHours = horasSonoDiarias ?? updatedSleepHours;
    current = UsuarioModel(
      id: current.id,
      nomeCompleto: nomeCompleto ?? current.nomeCompleto,
      email: current.email,
      horasSonoDiarias: horasSonoDiarias ?? current.horasSonoDiarias,
      onboardingConcluido: onboardingConcluido ?? current.onboardingConcluido,
    );
    return current;
  }

  @override
  Future<void> deleteAccount({String confirmacao = 'EXCLUIR'}) async {
    deleteAccountCalled = true;
  }

  @override
  Future<void> logout({required String refreshToken}) async {}

  @override
  Future<UsuarioModel> getMe() async => current;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  }) => throw UnimplementedError();

  @override
  Future<AuthSessionModel> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) => throw UnimplementedError();

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) =>
      throw UnimplementedError();

  @override
  Future<AuthSessionModel> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  }) => throw UnimplementedError();

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ConfigScreen, SleepHoursSelectorCard & DeleteAccountDialog (E02-T05)', () {
    testWidgets(
      'SleepHoursSelectorCard displays real-time RN02 capacity formula and saves updated sleep hours (RF05)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _ConfigFakeRemoteDataSource remote =
            _ConfigFakeRemoteDataSource();
        final InMemoryTokenStorage storage = InMemoryTokenStorage(
          initialAccessToken: 'token-1',
          initialRefreshToken: 'refresh-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRemoteDataSourceProvider.overrideWithValue(remote),
              secureTokenStorageProvider.overrideWithValue(storage),
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.authenticated(
                    UsuarioEntity(
                      id: 'user-config-1',
                      nomeCompleto: 'Carolina Calinca',
                      email: 'carolina@fatec.sp.gov.br',
                      horasSonoDiarias: 8,
                    ),
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: ConfigScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial 8h sleep formula
        expect(find.text('Carolina Calinca'), findsOneWidget);
        expect(
          find.text(
            'Capacidade útil diária: 16h (960 min) • Limite saudável (80%): 768 min',
          ),
          findsOneWidget,
        );

        // Decrement sleep hours from 8h to 7h
        await tester.tap(
          find.byKey(const Key('sleep_hours_decrement_button')),
        );
        await tester.pump();

        expect(
          find.text(
            'Capacidade útil diária: 17h (1020 min) • Limite saudável (80%): 816 min',
          ),
          findsOneWidget,
        );

        // Save new sleep hours
        final Finder saveSleepFinder = find.byKey(
          const Key('save_sleep_hours_button'),
        );
        await tester.ensureVisible(saveSleepFinder);
        await tester.tap(saveSleepFinder);
        await tester.pumpAndSettle();

        expect(remote.updatedSleepHours, equals(7));
      },
    );

    testWidgets(
      'DeleteAccountDialog requires explicit LGPD confirmation and deletes account on confirm (RNF07)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final _ConfigFakeRemoteDataSource remote =
            _ConfigFakeRemoteDataSource();
        final InMemoryTokenStorage storage = InMemoryTokenStorage(
          initialAccessToken: 'token-1',
          initialRefreshToken: 'refresh-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRemoteDataSourceProvider.overrideWithValue(remote),
              secureTokenStorageProvider.overrideWithValue(storage),
              authNotifierProvider.overrideWith(
                () => AuthNotifier(
                  initialState: const AuthState.authenticated(
                    UsuarioEntity(
                      id: 'user-config-1',
                      nomeCompleto: 'Carolina Calinca',
                      email: 'carolina@fatec.sp.gov.br',
                      horasSonoDiarias: 8,
                    ),
                  ),
                ),
              ),
            ],
            child: const MaterialApp(
              home: ConfigScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Expand section "Mais sobre minha conta"
        final Finder expansionTile =
            find.byKey(const Key('mais_sobre_conta_expansion_tile'));
        await tester.ensureVisible(expansionTile);
        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        final Finder openDeleteButton = find.byKey(
          const Key('open_delete_account_dialog_button'),
        );
        await tester.ensureVisible(openDeleteButton);
        await tester.tap(openDeleteButton);
        await tester.pumpAndSettle();

        expect(find.text('Excluir conta permanentemente?'), findsOneWidget);

        // Confirm button should be disabled before checking confirmation checkbox
        final ElevatedButton confirmBtnBefore = tester.widget<ElevatedButton>(
          find.byKey(const Key('delete_account_confirm_button')),
        );
        expect(confirmBtnBefore.onPressed, isNull);

        // Check LGPD agreement checkbox
        await tester.tap(
          find.byKey(const Key('delete_account_confirm_checkbox')),
        );
        await tester.pumpAndSettle();

        // Tap confirm delete button
        final Finder confirmBtnAfter =
          find.byKey(const Key('delete_account_confirm_button'));
        await tester.tap(confirmBtnAfter);
        await tester.pumpAndSettle();

        expect(remote.deleteAccountCalled, isTrue);
      },
    );
  });
}
