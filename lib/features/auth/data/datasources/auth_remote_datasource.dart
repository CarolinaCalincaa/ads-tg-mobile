import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/auth/data/models/usuario_model.dart';

/// Contrato da fonte de dados remota de Autenticação e Perfil (`Tech Doc 03 — Seção 2.1`).
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  });

  Future<AuthSessionModel> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  });

  Future<AuthSessionModel> loginWithGoogle({
    required String idToken,
  });

  Future<AuthSessionModel> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  });

  Future<void> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  });

  Future<UsuarioModel> getMe();

  Future<UsuarioModel> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  });

  Future<void> deleteAccount({
    String confirmacao = 'EXCLUIR',
  });

  Future<void> logout({
    required String refreshToken,
  });
}

/// Implementação de [AuthRemoteDataSource] via [Dio].
class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource({required this.dio});

  final Dio dio;

  Future<AuthSessionModel> _parseSessionOrFetchMe(
    Map<String, dynamic> data,
  ) async {
    final AuthSessionModel session = AuthSessionModel.fromJson(data);
    if (session.usuario.id.isNotEmpty && session.usuario.email.isNotEmpty) {
      return session;
    }

    final Response<dynamic> meResponse = await dio.get<dynamic>(
      '/usuarios/me',
      options: Options(
        headers: <String, dynamic>{
          'Authorization': 'Bearer ${session.accessToken}',
        },
      ),
    );

    final UsuarioModel fetchedUser = UsuarioModel.fromJson(
      meResponse.data as Map<String, dynamic>,
    );

    return AuthSessionModel(
      usuario: fetchedUser,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/auth/login',
      data: <String, dynamic>{
        'email': email.trim(),
        'senha': senha,
      },
    );
    return _parseSessionOrFetchMe(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthSessionModel> register({
    required String nomeCompleto,
    required String email,
    required String senha,
    int horasSonoDiarias = 8,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/auth/register',
      data: <String, dynamic>{
        'nomeCompleto': nomeCompleto.trim(),
        'email': email.trim(),
        'senha': senha,
        'horasSonoDiarias': horasSonoDiarias,
      },
    );
    return _parseSessionOrFetchMe(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthSessionModel> loginWithGoogle({
    required String idToken,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/auth/oauth/google',
      data: <String, dynamic>{
        'idToken': idToken,
      },
    );
    return _parseSessionOrFetchMe(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthSessionModel> loginWithApple({
    required String idToken,
    String? nomeCompleto,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'idToken': idToken,
      if (nomeCompleto != null && nomeCompleto.trim().isNotEmpty)
        'nomeCompleto': nomeCompleto.trim(),
    };
    final Response<dynamic> response = await dio.post<dynamic>(
      '/auth/oauth/apple',
      data: payload,
    );
    return _parseSessionOrFetchMe(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await dio.post<dynamic>(
      '/auth/forgot-password',
      data: <String, dynamic>{
        'email': email.trim(),
      },
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    await dio.post<dynamic>(
      '/auth/reset-password',
      data: <String, dynamic>{
        'email': email.trim(),
        'codigo': codigo.trim(),
        'novaSenha': novaSenha,
      },
    );
  }

  @override
  Future<UsuarioModel> getMe() async {
    final Response<dynamic> response = await dio.get<dynamic>('/usuarios/me');
    return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UsuarioModel> updateProfile({
    String? nomeCompleto,
    int? horasSonoDiarias,
    bool? onboardingConcluido,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      if (nomeCompleto != null) 'nomeCompleto': nomeCompleto.trim(),
      'horasSonoDiarias': ?horasSonoDiarias,
      'onboardingConcluido': ?onboardingConcluido,
    };
    final Response<dynamic> response = await dio.patch<dynamic>(
      '/usuarios/me',
      data: payload,
    );
    return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount({
    String confirmacao = 'EXCLUIR',
  }) async {
    await dio.delete<dynamic>(
      '/usuarios/me',
      data: <String, dynamic>{
        'confirmacao': confirmacao,
      },
    );
  }

  @override
  Future<void> logout({
    required String refreshToken,
  }) async {
    await dio.post<dynamic>(
      '/auth/logout',
      data: <String, dynamic>{
        'refreshToken': refreshToken,
      },
    );
  }
}

/// Provider global de [AuthRemoteDataSource].
final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((Ref ref) {
      return DioAuthRemoteDataSource(dio: ref.watch(dioProvider));
    });
