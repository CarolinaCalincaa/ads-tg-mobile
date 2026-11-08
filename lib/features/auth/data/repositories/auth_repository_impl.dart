import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';
import 'package:produtividade_tcc/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:produtividade_tcc/features/auth/data/models/usuario_model.dart';
import 'package:produtividade_tcc/features/auth/domain/entities/usuario_entity.dart';
import 'package:produtividade_tcc/features/auth/domain/repositories/auth_repository.dart';

/// Implementação concreta de [AuthRepository] para o MVP Online-First (`E02-T03`).
///
/// Orquestra chamadas via [AuthRemoteDataSource] e sincroniza `accessToken`,
/// `refreshToken` e snapshot de [UsuarioModel] com o [SecureTokenStorage].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final SecureTokenStorage tokenStorage;

  Future<void> _persistSession(AuthSessionModel session) async {
    await tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await tokenStorage.saveCachedUserJson(session.usuarioModel.toJson());
  }

  @override
  Future<Result<AuthSessionEntity>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final AuthSessionModel session = await remoteDataSource.login(
        email: email,
        senha: senha,
      );
      await _persistSession(session);
      return Success<AuthSessionEntity>(session);
    } catch (error) {
      return FailureResult<AuthSessionEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) async {
    try {
      final AuthSessionModel session = await remoteDataSource.register(
        nomeCompleto: nomeCompleto,
        email: email,
        senha: senha,
        horasSonoDiarias: horasSonoDiarias,
      );
      await _persistSession(session);
      return Success<AuthSessionEntity>(session);
    } catch (error) {
      return FailureResult<AuthSessionEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final AuthSessionModel session = await remoteDataSource.loginWithGoogle(
        idToken: idToken,
      );
      await _persistSession(session);
      return Success<AuthSessionEntity>(session);
    } catch (error) {
      return FailureResult<AuthSessionEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  }) async {
    try {
      final AuthSessionModel session = await remoteDataSource.loginWithApple(
        idToken: idToken,
        nomeCompleto: nomeCompleto,
      );
      await _persistSession(session);
      return Success<AuthSessionEntity>(session);
    } catch (error) {
      return FailureResult<AuthSessionEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<void>> forgotPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        codigo: codigo,
        novaSenha: novaSenha,
      );
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<UsuarioEntity>> getMe() async {
    try {
      final UsuarioModel user = await remoteDataSource.getMe();
      await tokenStorage.saveCachedUserJson(user.toJson());
      return Success<UsuarioEntity>(user);
    } catch (error) {
      return FailureResult<UsuarioEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<UsuarioEntity>> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    try {
      final UsuarioModel updated = await remoteDataSource.updateProfile(
        nomeCompleto: nomeCompleto,
        horasSonoDiarias: horasSonoDiarias,
        onboardingConcluido: onboardingConcluido,
      );
      await tokenStorage.saveCachedUserJson(updated.toJson());
      return Success<UsuarioEntity>(updated);
    } catch (error) {
      return FailureResult<UsuarioEntity>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<void>> deleteAccount({
    String confirmacao = 'EXCLUIR',
  }) async {
    try {
      await remoteDataSource.deleteAccount(confirmacao: confirmacao);
      await tokenStorage.clearAll();
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final String? refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.trim().isNotEmpty) {
        try {
          await remoteDataSource.logout(refreshToken: refreshToken);
        } catch (_) {
          // Mesmo se o servidor estiver inacessível, o logout local limpa os tokens.
        }
      }
      await tokenStorage.clearAll();
      return const Success<void>(null);
    } catch (error) {
      await tokenStorage.clearAll();
      return FailureResult<void>(ApiExceptionMapper.map(error));
    }
  }

  @override
  Future<UsuarioEntity?> getHydratedUser() async {
    final String? accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.trim().isEmpty) {
      return null;
    }

    final Map<String, dynamic>? cachedJson = await tokenStorage
        .getCachedUserJson();
    if (cachedJson != null) {
      final UsuarioModel cachedUser = UsuarioModel.fromJson(cachedJson);
      if (cachedUser.id.isNotEmpty) {
        return cachedUser;
      }
    }

    final Result<UsuarioEntity> meResult = await getMe();
    return meResult.dataOrNull;
  }
}

/// Provider global de [AuthRepository].
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
      return AuthRepositoryImpl(
        remoteDataSource: ref.watch(authRemoteDataSourceProvider),
        tokenStorage: ref.watch(secureTokenStorageProvider),
      );
    });
