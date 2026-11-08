import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/auth_interceptor.dart';
import 'package:produtividade_tcc/core/router/app_router.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';
import 'package:produtividade_tcc/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:produtividade_tcc/features/auth/data/models/usuario_model.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/presentation/providers/auth_notifier.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  UsuarioModel currentUser = const UsuarioModel(
    id: 'uuid-user-1',
    nomeCompleto: 'Carolina Calinca',
    email: 'carolina@fatec.sp.gov.br',
    provedorOauth: ProvedorOAuth.local,
    horasSonoDiarias: 8,
    onboardingConcluido: false,
  );

  bool shouldFailLogin = false;
  String? lastGoogleIdToken;
  String? lastAppleIdToken;
  bool accountDeleted = false;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  }) async {
    if (shouldFailLogin) {
      throw const UnauthorizedFailure(message: 'Credenciais inválidas.');
    }
    return AuthSessionModel(
      usuario: currentUser,
      accessToken: 'jwt-access-token',
      refreshToken: 'jwt-refresh-token',
    );
  }

  @override
  Future<AuthSessionModel> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) async {
    currentUser = UsuarioModel(
      id: 'uuid-user-new',
      nomeCompleto: nomeCompleto,
      email: email,
      provedorOauth: ProvedorOAuth.local,
      horasSonoDiarias: horasSonoDiarias,
      onboardingConcluido: false,
    );
    return AuthSessionModel(
      usuario: currentUser,
      accessToken: 'register-access-token',
      refreshToken: 'register-refresh-token',
    );
  }

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) async {
    lastGoogleIdToken = idToken;
    currentUser = const UsuarioModel(
      id: 'uuid-google-1',
      nomeCompleto: 'Carolina Google',
      email: 'carolina.google@fatec.sp.gov.br',
      provedorOauth: ProvedorOAuth.google,
      horasSonoDiarias: 8,
      onboardingConcluido: true,
    );
    return AuthSessionModel(
      usuario: currentUser,
      accessToken: 'google-access',
      refreshToken: 'google-refresh',
    );
  }

  @override
  Future<AuthSessionModel> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  }) async {
    lastAppleIdToken = idToken;
    currentUser = UsuarioModel(
      id: 'uuid-apple-1',
      nomeCompleto: nomeCompleto ?? 'Carolina Apple',
      email: 'carolina.apple@fatec.sp.gov.br',
      provedorOauth: ProvedorOAuth.apple,
      horasSonoDiarias: 8,
      onboardingConcluido: true,
    );
    return AuthSessionModel(
      usuario: currentUser,
      accessToken: 'apple-access',
      refreshToken: 'apple-refresh',
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
  Future<UsuarioModel> getMe() async => currentUser;

  @override
  Future<UsuarioModel> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    currentUser = UsuarioModel(
      id: currentUser.id,
      nomeCompleto: nomeCompleto ?? currentUser.nomeCompleto,
      email: currentUser.email,
      provedorOauth: currentUser.provedorOauth,
      horasSonoDiarias: horasSonoDiarias ?? currentUser.horasSonoDiarias,
      onboardingConcluido:
          onboardingConcluido ?? currentUser.onboardingConcluido,
    );
    return currentUser;
  }

  @override
  Future<void> deleteAccount({String confirmacao = 'EXCLUIR'}) async {
    accountDeleted = true;
  }

  @override
  Future<void> logout({required String refreshToken}) async {}
}

void main() {
  group('UsuarioEntity RN02 Calculations & Helpers (E02-T03)', () {
    test(
      'computes minutosUteisDiarios and limiteFadigaMinutos accurately for 8h and 7h sleep',
      () {
        const UsuarioEntity user8h = UsuarioEntity(
          id: '1',
          nomeCompleto: 'Carolina Calinca',
          email: 'carolina@fatec.sp.gov.br',
          horasSonoDiarias: 8,
        );
        expect(user8h.horasUteisDiarias, equals(16));
        expect(user8h.minutosUteisDiarios, equals(960));
        expect(user8h.limiteFadigaMinutos, equals(768));
        expect(user8h.primeiroNome, equals('Carolina'));
        expect(user8h.iniciais, equals('CC'));

        final UsuarioEntity user7h = user8h.copyWith(horasSonoDiarias: 7);
        expect(user7h.horasUteisDiarias, equals(17));
        expect(user7h.minutosUteisDiarios, equals(1020));
        expect(user7h.limiteFadigaMinutos, equals(816));
      },
    );
  });

  group('AuthRepositoryImpl & AuthNotifier (E02-T03)', () {
    late _FakeAuthRemoteDataSource fakeRemote;
    late InMemoryTokenStorage tokenStorage;
    late ProviderContainer container;

    setUp(() {
      fakeRemote = _FakeAuthRemoteDataSource();
      tokenStorage = InMemoryTokenStorage();
      container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(fakeRemote),
          secureTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'login persists tokens and transitions AuthNotifier to authenticated',
      () async {
        final AuthNotifier notifier = container.read(
          authNotifierProvider.notifier,
        );
        await Future<void>.delayed(Duration.zero);

        final bool ok = await notifier.login(
          email: 'carolina@fatec.sp.gov.br',
          senha: 'Password@123',
        );

        expect(ok, isTrue);
        final AuthState state = container.read(authNotifierProvider);
        expect(state.status, equals(AuthStatus.authenticated));
        expect(state.usuario?.email, equals('carolina@fatec.sp.gov.br'));
        expect(await tokenStorage.getAccessToken(), equals('jwt-access-token'));
        expect(
          await tokenStorage.getRefreshToken(),
          equals('jwt-refresh-token'),
        );
      },
    );

    test(
      'loginWithGoogle and loginWithApple send dev mock tokens when no idToken is passed',
      () async {
        final AuthNotifier notifier = container.read(
          authNotifierProvider.notifier,
        );
        await Future<void>.delayed(Duration.zero);

        final bool googleOk = await notifier.loginWithGoogle();
        expect(googleOk, isTrue);
        expect(fakeRemote.lastGoogleIdToken, startsWith('mock-google-token:'));
        expect(
          container.read(authNotifierProvider).usuario?.provedorOauth,
          equals(ProvedorOAuth.google),
        );

        final bool appleOk = await notifier.loginWithApple();
        expect(appleOk, isTrue);
        expect(fakeRemote.lastAppleIdToken, startsWith('mock-apple-token:'));
        expect(
          container.read(authNotifierProvider).usuario?.provedorOauth,
          equals(ProvedorOAuth.apple),
        );
      },
    );

    test(
      'updateProfile updates horasSonoDiarias and deleteAccount clears storage and logs out',
      () async {
        final AuthNotifier notifier = container.read(
          authNotifierProvider.notifier,
        );
        await notifier.login(
          email: 'carolina@fatec.sp.gov.br',
          senha: 'Password@123',
        );

        final Result<UsuarioEntity> updateRes = await notifier.updateProfile(
          nomeCompleto: 'Carolina Atualizada',
          horasSonoDiarias: 7,
        );
        expect(updateRes.isSuccess, isTrue);
        expect(
          container.read(authNotifierProvider).usuario?.horasSonoDiarias,
          equals(7),
        );
        expect(
          container.read(authNotifierProvider).usuario?.limiteFadigaMinutos,
          equals(816),
        );

        final Result<void> deleteRes = await notifier.deleteAccount();
        expect(deleteRes.isSuccess, isTrue);
        expect(fakeRemote.accountDeleted, isTrue);
        expect(
          container.read(authNotifierProvider).status,
          equals(AuthStatus.unauthenticated),
        );
        expect(await tokenStorage.getAccessToken(), isNull);
      },
    );

    test(
      'AuthSessionEventBus transitions AuthNotifier to unauthenticated when interceptor signals 401 expiry',
      () async {
        final AuthNotifier notifier = container.read(
          authNotifierProvider.notifier,
        );
        await notifier.login(
          email: 'carolina@fatec.sp.gov.br',
          senha: 'Password@123',
        );
        expect(container.read(authNotifierProvider).isAuthenticated, isTrue);

        container.read(authSessionEventBusProvider).notifyUnauthorized();
        expect(
          container.read(authNotifierProvider).status,
          equals(AuthStatus.unauthenticated),
        );
      },
    );
  });

  group('GoRouter Auth Guard (evaluateAuthRedirect — E02-T03)', () {
    const UsuarioEntity mockUser = UsuarioEntity(
      id: 'u1',
      nomeCompleto: 'Carolina',
      email: 'carolina@fatec.sp.gov.br',
    );

    test(
      'redirects unauthenticated users from protected routes to /login while allowing public auth routes',
      () {
        const AuthState unauth = AuthState.unauthenticated();

        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.painel,
          ),
          equals(AppRoutes.login),
        );
        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.config,
          ),
          equals(AppRoutes.login),
        );
        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.login,
          ),
          isNull,
        );
        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.register,
          ),
          isNull,
        );
        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.forgotPassword,
          ),
          isNull,
        );
        expect(
          evaluateAuthRedirect(
            authState: unauth,
            matchedLocation: AppRoutes.resetPassword,
          ),
          isNull,
        );
      },
    );

    test(
      'redirects authenticated users away from /login and /register to /painel',
      () {
        const AuthState auth = AuthState.authenticated(mockUser);

        expect(
          evaluateAuthRedirect(
            authState: auth,
            matchedLocation: AppRoutes.login,
          ),
          equals(AppRoutes.painel),
        );
        expect(
          evaluateAuthRedirect(
            authState: auth,
            matchedLocation: AppRoutes.register,
          ),
          equals(AppRoutes.painel),
        );
        expect(
          evaluateAuthRedirect(
            authState: auth,
            matchedLocation: AppRoutes.painel,
          ),
          isNull,
        );
        expect(
          evaluateAuthRedirect(
            authState: auth,
            matchedLocation: AppRoutes.config,
          ),
          isNull,
        );
      },
    );
  });
}
