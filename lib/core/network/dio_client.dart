import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';

/// Cliente HTTP centralizado da aplicação configurado para a API NestJS (`Tech Doc 01` e `Tech Doc 03`).
class DioClient {
  DioClient({Dio? dio}) : _dio = dio ?? _createDefaultDio();

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

/// Provider global do [DioClient] para injeção nos `RemoteDataSources`.
final Provider<DioClient> dioClientProvider = Provider<DioClient>((Ref ref) {
  return DioClient();
});

/// Provider direto da instância [Dio] configurada.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  return ref.watch(dioClientProvider).instance;
});
