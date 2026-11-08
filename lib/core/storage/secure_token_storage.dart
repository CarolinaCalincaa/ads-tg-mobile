import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contrato de armazenamento seguro de credenciais de sessão (`ADR-005` e `RNF05`).
///
/// Armazena `accessToken`, `refreshToken` e um snapshot JSON opcional do usuário
/// para hidratação imediata da sessão na inicialização do aplicativo.
abstract interface class SecureTokenStorage {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<Map<String, dynamic>?> getCachedUserJson();

  Future<void> saveCachedUserJson(Map<String, dynamic> userJson);

  Future<void> clearAll();
}

/// Implementação de [SecureTokenStorage] baseada em [FlutterSecureStorage]
/// (Keychain no iOS, Keystore/EncryptedStorage no Android e WebCrypto na Web).
class FlutterSecureTokenStorage implements SecureTokenStorage {
  FlutterSecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String cachedUserKey = 'auth_cached_user_json';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: refreshTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait(<Future<void>>[
      _storage.write(key: accessTokenKey, value: accessToken),
      _storage.write(key: refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserJson() async {
    final String? raw = await _storage.read(key: cachedUserKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedUserJson(Map<String, dynamic> userJson) {
    return _storage.write(
      key: cachedUserKey,
      value: jsonEncode(userJson),
    );
  }

  @override
  Future<void> clearAll() async {
    await Future.wait(<Future<void>>[
      _storage.delete(key: accessTokenKey),
      _storage.delete(key: refreshTokenKey),
      _storage.delete(key: cachedUserKey),
    ]);
  }
}

/// Implementação em memória de [SecureTokenStorage] para testes unitários e de widget.
class InMemoryTokenStorage implements SecureTokenStorage {
  InMemoryTokenStorage({
    String? initialAccessToken,
    String? initialRefreshToken,
    Map<String, dynamic>? initialUserJson,
  }) : _accessToken = initialAccessToken,
       _refreshToken = initialRefreshToken,
       _cachedUserJson = initialUserJson;

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _cachedUserJson;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserJson() async => _cachedUserJson;

  @override
  Future<void> saveCachedUserJson(Map<String, dynamic> userJson) async {
    _cachedUserJson = Map<String, dynamic>.from(userJson);
  }

  @override
  Future<void> clearAll() async {
    _accessToken = null;
    _refreshToken = null;
    _cachedUserJson = null;
  }
}

/// Provider global de [SecureTokenStorage].
final Provider<SecureTokenStorage> secureTokenStorageProvider =
    Provider<SecureTokenStorage>((Ref ref) {
      return FlutterSecureTokenStorage();
    });
