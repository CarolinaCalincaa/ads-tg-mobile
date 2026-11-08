import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/auth_interceptor.dart';
import 'package:produtividade_tcc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/domain/repositories/auth_repository.dart';

/// Estados possíveis do ciclo de vida de autenticação (`E02-T03`).
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Estado imutável de autenticação gerenciado pelo [AuthNotifier].
class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.usuario,
    this.failure,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading({UsuarioEntity? usuario})
    : this(status: AuthStatus.loading, usuario: usuario);

  const AuthState.authenticated(UsuarioEntity usuario)
    : this(status: AuthStatus.authenticated, usuario: usuario);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.error(AppFailure failure, {UsuarioEntity? usuario})
    : this(status: AuthStatus.error, usuario: usuario, failure: failure);

  final AuthStatus status;
  final UsuarioEntity? usuario;
  final AppFailure? failure;

  bool get isAuthenticated =>
      (status == AuthStatus.authenticated ||
          (status == AuthStatus.loading && usuario != null) ||
          (status == AuthStatus.error && usuario != null)) &&
      usuario != null;

  bool get isLoading => status == AuthStatus.loading;

  String? get errorMessage => failure?.message;

  AuthState copyWith({
    AuthStatus? status,
    UsuarioEntity? usuario,
    AppFailure? failure,
    bool clearFailure = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      usuario: clearUser ? null : (usuario ?? this.usuario),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, usuario, failure];
}

/// Notifier Riverpod responsável pela sessão de autenticação, login local/OAuth,
/// atualização de perfil (`RF05`) e exclusão definitiva LGPD (`RNF07`).
class AuthNotifier extends Notifier<AuthState> {
  AuthNotifier({AuthState? initialState}) : _initialOverride = initialState;

  final AuthState? _initialOverride;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    final AuthSessionEventBus eventBus = ref.watch(authSessionEventBusProvider);
    void onUnauthorized() {
      state = const AuthState.unauthenticated();
    }

    eventBus.addListener(onUnauthorized);
    ref.onDispose(() {
      eventBus.removeListener(onUnauthorized);
    });

    if (_initialOverride != null) {
      return _initialOverride;
    }

    Future<void>.microtask(hydrateSession);
    return const AuthState.initial();
  }

  /// Hidrata a sessão a partir do [SecureTokenStorage] na inicialização do app.
  Future<void> hydrateSession() async {
    try {
      final UsuarioEntity? hydratedUser = await _repository.getHydratedUser();
      if (hydratedUser != null) {
        state = AuthState.authenticated(hydratedUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Realiza login com e-mail e senha (`RF03`).
  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    state = const AuthState.loading();
    final Result<AuthSessionEntity> result = await _repository.login(
      email: email,
      senha: senha,
    );
    return result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure);
        return false;
      },
      onSuccess: (AuthSessionEntity session) {
        state = AuthState.authenticated(session.usuario);
        return true;
      },
    );
  }

  /// Registra nova conta local (`RF01`, `RF02`).
  Future<bool> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) async {
    state = const AuthState.loading();
    final Result<AuthSessionEntity> result = await _repository.register(
      nomeCompleto: nomeCompleto,
      email: email,
      senha: senha,
      horasSonoDiarias: horasSonoDiarias,
    );
    return result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure);
        return false;
      },
      onSuccess: (AuthSessionEntity session) {
        state = AuthState.authenticated(session.usuario);
        return true;
      },
    );
  }

  /// Realiza login via Google OAuth 2.0 (`RF03`).
  ///
  /// Quando `idToken` não é fornecido e [EnvConfig.oauthDevMockEnabled] está ativo,
  /// utiliza `mock-google-token:<email>` para integração imediata com o backend local (`ADR-005`).
  Future<bool> loginWithGoogle({
    String? idToken,
    String? mockEmail,
  }) async {
    state = const AuthState.loading();
    final String resolvedToken =
        (idToken != null && idToken.trim().isNotEmpty)
        ? idToken.trim()
        : (EnvConfig.oauthDevMockEnabled || EnvConfig.googleClientId.isEmpty
              ? 'mock-google-token:${(mockEmail != null && mockEmail.trim().isNotEmpty) ? mockEmail.trim() : 'carolina.google@fatec.sp.gov.br'}'
              : '');

    final Result<AuthSessionEntity> result = await _repository.loginWithGoogle(
      idToken: resolvedToken,
    );
    return result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure);
        return false;
      },
      onSuccess: (AuthSessionEntity session) {
        state = AuthState.authenticated(session.usuario);
        return true;
      },
    );
  }

  /// Realiza login via Apple Sign-In (`RF03`).
  ///
  /// Quando `idToken` não é fornecido e [EnvConfig.oauthDevMockEnabled] está ativo,
  /// utiliza `mock-apple-token:<email>` para integração imediata com o backend local (`ADR-005`).
  Future<bool> loginWithApple({
    String? idToken,
    String? nomeCompleto,
    String? mockEmail,
  }) async {
    state = const AuthState.loading();
    final String resolvedToken =
        (idToken != null && idToken.trim().isNotEmpty)
        ? idToken.trim()
        : (EnvConfig.oauthDevMockEnabled || EnvConfig.appleClientId.isEmpty
              ? 'mock-apple-token:${(mockEmail != null && mockEmail.trim().isNotEmpty) ? mockEmail.trim() : 'carolina.apple@fatec.sp.gov.br'}'
              : '');

    final Result<AuthSessionEntity> result = await _repository.loginWithApple(
      idToken: resolvedToken,
      nomeCompleto: nomeCompleto,
    );
    return result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure);
        return false;
      },
      onSuccess: (AuthSessionEntity session) {
        state = AuthState.authenticated(session.usuario);
        return true;
      },
    );
  }

  /// Solicita código de 6 dígitos para recuperação de senha (`RF04`).
  Future<Result<void>> forgotPassword({
    required String email,
  }) {
    return _repository.forgotPassword(email: email);
  }

  /// Redefine a senha com o código temporário recebido (`RF04`).
  Future<Result<void>> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) {
    return _repository.resetPassword(
      email: email,
      codigo: codigo,
      novaSenha: novaSenha,
    );
  }

  /// Recarrega os dados do perfil autenticado (`GET /usuarios/me`).
  Future<Result<UsuarioEntity>> refreshProfile() async {
    final Result<UsuarioEntity> result = await _repository.getMe();
    result.fold(
      onFailure: (_) {},
      onSuccess: (UsuarioEntity updated) {
        state = AuthState.authenticated(updated);
      },
    );
    return result;
  }

  /// Atualiza `nomeCompleto`, `horasSonoDiarias` (`RF05`) ou `onboardingConcluido`.
  Future<Result<UsuarioEntity>> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    final UsuarioEntity? currentUser = state.usuario;
    state = AuthState.loading(usuario: currentUser);

    final Result<UsuarioEntity> result = await _repository.updateProfile(
      nomeCompleto: nomeCompleto,
      horasSonoDiarias: horasSonoDiarias,
      onboardingConcluido: onboardingConcluido,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure, usuario: currentUser);
      },
      onSuccess: (UsuarioEntity updatedUser) {
        state = AuthState.authenticated(updatedUser);
      },
    );

    return result;
  }

  /// Exclui permanentemente a conta e todos os dados (LGPD — `RNF07`) e redireciona para `/login`.
  Future<Result<void>> deleteAccount({
    String confirmacao = 'EXCLUIR',
  }) async {
    final UsuarioEntity? currentUser = state.usuario;
    state = AuthState.loading(usuario: currentUser);

    final Result<void> result = await _repository.deleteAccount(
      confirmacao: confirmacao,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        state = AuthState.error(failure, usuario: currentUser);
      },
      onSuccess: (_) {
        state = const AuthState.unauthenticated();
      },
    );

    return result;
  }

  /// Encerra a sessão atual e redireciona para `/login`.
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }

  /// Limpa erros transitórios de formulário/UI mantendo o estado atual.
  void clearError() {
    if (state.usuario != null) {
      state = AuthState.authenticated(state.usuario!);
    } else {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Provider global do [AuthNotifier].
final NotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Adaptador [ChangeNotifier] para notificar o `GoRouter` sobre transições de autenticação.
class RouterAuthRefreshNotifier extends ChangeNotifier {
  RouterAuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(
      authNotifierProvider,
      (AuthState? previous, AuthState next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }
}
