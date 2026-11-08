import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';
import 'package:produtividade_tcc/core/network/auth_interceptor.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';

/// Cliente HTTP centralizado da aplicação configurado para a API NestJS (`Tech Doc 01` e `Tech Doc 03`).
class DioClient {
  DioClient({
    Dio? dio,
    SecureTokenStorage? tokenStorage,
    Dio? refreshDio,
    VoidCallback? onUnauthorized,
  }) : _dio = dio ?? _createDefaultDio() {
    if (tokenStorage != null) {
      _dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          retryDio: _dio,
          refreshDio: refreshDio,
          onUnauthorized: onUnauthorized,
        ),
      );
    }
  }

  final Dio _dio;

  Dio get instance => _dio;

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      ),
    );
  }
}

/// Provider global do [DioClient] com [AuthInterceptor] acoplado para injeção nos `RemoteDataSources`.
final Provider<DioClient> dioClientProvider = Provider<DioClient>((Ref ref) {
  final SecureTokenStorage tokenStorage = ref.watch(secureTokenStorageProvider);
  final AuthSessionEventBus eventBus = ref.watch(authSessionEventBusProvider);

  return DioClient(
    tokenStorage: tokenStorage,
    onUnauthorized: eventBus.notifyUnauthorized,
  );
});

/// Provider direto da instância [Dio] configurada.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  return ref.watch(dioClientProvider).instance;
});
