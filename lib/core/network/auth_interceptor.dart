import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';

/// Barramento reativo leve para notificar expiração definitiva de sessão (`401` após falha de refresh)
/// sem criar dependência circular entre `DioClient` e `AuthNotifier`.
class AuthSessionEventBus extends ChangeNotifier {
  int _unauthorizedCount = 0;

  int get unauthorizedCount => _unauthorizedCount;

  void notifyUnauthorized() {
    _unauthorizedCount++;
    notifyListeners();
  }
}

/// Provider global do [AuthSessionEventBus].
final Provider<AuthSessionEventBus> authSessionEventBusProvider =
    Provider<AuthSessionEventBus>((Ref ref) {
      final AuthSessionEventBus bus = AuthSessionEventBus();
      ref.onDispose(bus.dispose);
      return bus;
    });

/// Interceptor HTTP responsável por (`ADR-005` e `E02-T03`):
/// 1. Anexar `Authorization: Bearer <accessToken>` em todas as requisições.
/// 2. Ao receber `HTTP 401` em rotas autenticadas, acionar `POST /auth/refresh`,
///    persistir o novo par de tokens no [SecureTokenStorage] e reenviar a requisição original.
/// 3. Caso a renovação falhe, limpar o storage seguro e notificar logout forçado.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.retryDio,
    Dio? refreshDio,
    this.onUnauthorized,
  }) : _refreshDio = refreshDio ?? _createDefaultRefreshDio(retryDio);

  static const String _retriedFlag = '_auth_retried';

  static const Set<String> _unauthenticatedAuthPaths = <String>{
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/oauth/google',
    '/auth/oauth/apple',
    '/auth/forgot-password',
    '/auth/reset-password',
  };

  final SecureTokenStorage tokenStorage;
  final Dio retryDio;
  final Dio _refreshDio;
  final VoidCallback? onUnauthorized;

  static Dio _createDefaultRefreshDio(Dio baseDio) {
    return Dio(
      BaseOptions(
        baseUrl: baseDio.options.baseUrl.isNotEmpty
            ? baseDio.options.baseUrl
            : EnvConfig.apiBaseUrl,
        connectTimeout: EnvConfig.connectTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      ),
    );
  }

  bool _isPublicAuthEndpoint(String path) {
    final String normalized = path.toLowerCase();
    for (final String authPath in _unauthenticatedAuthPaths) {
      if (normalized.endsWith(authPath) || normalized.contains('$authPath?')) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuthEndpoint(options.path)) {
      final String? accessToken = await tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int? statusCode = err.response?.statusCode;
    final RequestOptions requestOptions = err.requestOptions;
    final bool alreadyRetried = requestOptions.extra[_retriedFlag] == true;

    if (statusCode != 401 ||
        alreadyRetried ||
        _isPublicAuthEndpoint(requestOptions.path)) {
      handler.next(err);
      return;
    }

    final String? refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await _handleSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final Response<dynamic> refreshResponse = await _refreshDio.post<dynamic>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      final dynamic rawData = refreshResponse.data;
      if (rawData is! Map<String, dynamic>) {
        await _handleSessionExpired();
        handler.next(err);
        return;
      }

      final Map<String, dynamic> payload =
          rawData['data'] is Map<String, dynamic>
          ? rawData['data'] as Map<String, dynamic>
          : rawData;

      final String? newAccessToken = payload['accessToken'] as String?;
      final String? newRefreshToken = payload['refreshToken'] as String?;

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        await _handleSessionExpired();
        handler.next(err);
        return;
      }

      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final Map<String, dynamic> updatedHeaders = Map<String, dynamic>.from(
        requestOptions.headers,
      )..['Authorization'] = 'Bearer $newAccessToken';

      final Map<String, dynamic> updatedExtra = Map<String, dynamic>.from(
        requestOptions.extra,
      )..[_retriedFlag] = true;

      final Options retryOptions = Options(
        method: requestOptions.method,
        headers: updatedHeaders,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        extra: updatedExtra,
      );

      final Response<dynamic> retryResponse = await retryDio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        cancelToken: requestOptions.cancelToken,
        options: retryOptions,
        onSendProgress: requestOptions.onSendProgress,
        onReceiveProgress: requestOptions.onReceiveProgress,
      );

      handler.resolve(retryResponse);
    } on DioException {
      await _handleSessionExpired();
      handler.next(err);
    } catch (_) {
      await _handleSessionExpired();
      handler.next(err);
    }
  }

  Future<void> _handleSessionExpired() async {
    await tokenStorage.clearAll();
    onUnauthorized?.call();
  }
}
