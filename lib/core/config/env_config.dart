/// Configurações de ambiente injetadas em tempo de compilação via `--dart-define`.
abstract final class EnvConfig {
  /// URL base da API REST central (NestJS).
  ///
  /// Pode ser sobrescrita com `--dart-define=API_BASE_URL=https://...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  /// Timeout de conexão HTTP padrão (5 segundos).
  static const Duration connectTimeout = Duration(seconds: 5);

  /// Timeout de leitura/recebimento HTTP padrão (5 segundos).
  static const Duration receiveTimeout = Duration(seconds: 5);

  /// Nome de exibição da aplicação.
  static const String appName = 'Calma Cognitiva';
}
