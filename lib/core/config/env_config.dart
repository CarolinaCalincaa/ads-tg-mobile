/// Configurações de ambiente injetadas em tempo de compilação via `--dart-define`.
abstract final class EnvConfig {
  /// URL base da API REST central (NestJS).
  ///
  /// Pode ser sobrescrita com `--dart-define=API_BASE_URL=https://...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  /// Client ID OAuth 2.0 do Google (opcional em dev quando mock está ativo).
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '699977329205-18v8siu77o9n3b5e6a07vglpnclob0bn.apps.googleusercontent.com',
  );

  /// Client ID / Service ID OAuth 2.0 da Apple (opcional em dev quando mock está ativo).
  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Habilita tokens OAuth simulados (`mock-google-token:<email>` / `mock-apple-token:<email>`)
  /// em ambiente local de desenvolvimento (`ADR-005`).
  static const bool oauthDevMockEnabled = bool.fromEnvironment(
    'OAUTH_DEV_MOCK_ENABLED',
    defaultValue: true,
  );

  /// Timeout de conexão HTTP padrão (5 segundos).
  static const Duration connectTimeout = Duration(seconds: 5);

  /// Timeout de leitura/recebimento HTTP padrão (5 segundos).
  static const Duration receiveTimeout = Duration(seconds: 5);

  /// Nome de exibição da aplicação.
  static const String appName = 'Calma Cognitiva';
}
