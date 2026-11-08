import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/core/network/auth_interceptor.dart';
import 'package:produtividade_tcc/core/storage/secure_token_storage.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

void main() {
  group('AuthInterceptor (E02-T03)', () {
    test(
      'attaches Authorization Bearer header on protected endpoints and skips public auth endpoints',
      () async {
        final InMemoryTokenStorage storage = InMemoryTokenStorage(
          initialAccessToken: 'access-123',
          initialRefreshToken: 'refresh-123',
        );

        final List<RequestOptions> capturedRequests = <RequestOptions>[];
        final Dio dio = Dio(
          BaseOptions(baseUrl: 'http://localhost:3000/api/v1'),
        );
        dio.httpClientAdapter = _FakeHttpClientAdapter((
          RequestOptions options,
        ) async {
          capturedRequests.add(options);
          return _jsonResponse(<String, dynamic>{'ok': true});
        });

        dio.interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            retryDio: dio,
          ),
        );

        await dio.get<dynamic>('/usuarios/me');
        await dio.post<dynamic>('/auth/login', data: <String, dynamic>{});

        expect(capturedRequests, hasLength(2));
        expect(
          capturedRequests[0].headers['Authorization'],
          equals('Bearer access-123'),
        );
        expect(
          capturedRequests[1].headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

    test(
      'automatically refreshes token on 401 and transparently retries the original request',
      () async {
        final InMemoryTokenStorage storage = InMemoryTokenStorage(
          initialAccessToken: 'expired-access-token',
          initialRefreshToken: 'valid-refresh-token',
        );

        int protectedCallCount = 0;
        int refreshCallCount = 0;
        bool unauthorizedCalled = false;

        final Dio mainDio = Dio(
          BaseOptions(baseUrl: 'http://localhost:3000/api/v1'),
        );
        final Dio refreshDio = Dio(
          BaseOptions(baseUrl: 'http://localhost:3000/api/v1'),
        );

        refreshDio.httpClientAdapter = _FakeHttpClientAdapter((
          RequestOptions options,
        ) async {
          refreshCallCount++;
          expect(options.path, equals('/auth/refresh'));
          return _jsonResponse(<String, dynamic>{
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          });
        });

        mainDio.httpClientAdapter = _FakeHttpClientAdapter((
          RequestOptions options,
        ) async {
          protectedCallCount++;
          final String? authHeader =
              options.headers['Authorization'] as String?;
          if (authHeader == 'Bearer expired-access-token') {
            return _jsonResponse(
              <String, dynamic>{
                'statusCode': 401,
                'errorCode': 'TOKEN_EXPIRED_OR_INVALID',
                'message': 'Token expirado.',
              },
              statusCode: 401,
            );
          }
          expect(authHeader, equals('Bearer new-access-token'));
          return _jsonResponse(<String, dynamic>{
            'id': 'user-1',
            'nomeCompleto': 'Carolina Silva',
          });
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            retryDio: mainDio,
            refreshDio: refreshDio,
            onUnauthorized: () {
              unauthorizedCalled = true;
            },
          ),
        );

        final Response<dynamic> response = await mainDio.get<dynamic>(
          '/usuarios/me',
        );

        expect(response.statusCode, equals(200));
        expect(
          (response.data as Map<String, dynamic>)['nomeCompleto'],
          equals('Carolina Silva'),
        );
        expect(protectedCallCount, equals(2));
        expect(refreshCallCount, equals(1));
        expect(unauthorizedCalled, isFalse);
        expect(await storage.getAccessToken(), equals('new-access-token'));
        expect(await storage.getRefreshToken(), equals('new-refresh-token'));
      },
    );

    test(
      'clears storage and invokes onUnauthorized when token refresh fails on 401',
      () async {
        final InMemoryTokenStorage storage = InMemoryTokenStorage(
          initialAccessToken: 'expired-access-token',
          initialRefreshToken: 'expired-refresh-token',
        );

        bool unauthorizedCalled = false;

        final Dio mainDio = Dio(
          BaseOptions(baseUrl: 'http://localhost:3000/api/v1'),
        );
        final Dio refreshDio = Dio(
          BaseOptions(baseUrl: 'http://localhost:3000/api/v1'),
        );

        refreshDio.httpClientAdapter = _FakeHttpClientAdapter((
          RequestOptions options,
        ) async {
          return _jsonResponse(
            <String, dynamic>{
              'statusCode': 401,
              'errorCode': 'TOKEN_EXPIRED_OR_INVALID',
              'message': 'Refresh inválido.',
            },
            statusCode: 401,
          );
        });

        mainDio.httpClientAdapter = _FakeHttpClientAdapter((
          RequestOptions options,
        ) async {
          return _jsonResponse(
            <String, dynamic>{
              'statusCode': 401,
              'errorCode': 'TOKEN_EXPIRED_OR_INVALID',
              'message': 'Access expirado.',
            },
            statusCode: 401,
          );
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            retryDio: mainDio,
            refreshDio: refreshDio,
            onUnauthorized: () {
              unauthorizedCalled = true;
            },
          ),
        );

        await expectLater(
          () => mainDio.get<dynamic>('/usuarios/me'),
          throwsA(isA<DioException>()),
        );

        expect(unauthorizedCalled, isTrue);
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
      },
    );
  });
}
