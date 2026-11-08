import 'package:equatable/equatable.dart';

/// Hierarquia selada de falhas de domínio e infraestrutura da aplicação.
///
/// Traduz o envelope padronizado do `GlobalHttpExceptionFilter` do NestJS
/// (`statusCode`, `errorCode`, `message`, `details`) para tipos seguros no Flutter.
sealed class AppFailure extends Equatable {
  const AppFailure({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? errorCode;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => <Object?>[message, errorCode, statusCode, details];
}

/// Falha de validação de dados de entrada (`HTTP 400 VALIDATION_ERROR`).
final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    super.message = 'Dados inválidos. Verifique os campos informados.',
    super.errorCode = 'VALIDATION_ERROR',
    super.statusCode = 400,
    super.details,
  });
}

/// Falha de autenticação ou sessão expirada (`HTTP 401 INVALID_CREDENTIALS` / `TOKEN_EXPIRED_OR_INVALID`).
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'Sessão expirada ou credenciais inválidas.',
    super.errorCode = 'TOKEN_EXPIRED_OR_INVALID',
    super.statusCode = 401,
    super.details,
  });
}

/// Conflito de e-mail já registrado (`HTTP 409 EMAIL_ALREADY_REGISTERED` — `RF01`).
final class EmailAlreadyRegisteredFailure extends AppFailure {
  const EmailAlreadyRegisteredFailure({
    super.message = 'Este e-mail já está cadastrado.',
    super.errorCode = 'EMAIL_ALREADY_REGISTERED',
    super.statusCode = 409,
    super.details,
  });
}

/// Token de recuperação de senha inválido ou expirado (`HTTP 400 RESET_TOKEN_INVALID` — `RF04`).
final class ResetTokenInvalidFailure extends AppFailure {
  const ResetTokenInvalidFailure({
    super.message = 'Código de recuperação inválido ou expirado.',
    super.errorCode = 'RESET_TOKEN_INVALID',
    super.statusCode = 400,
    super.details,
  });
}

/// Violação da Regra de Negócio RN01: Máximo de 3 Pilares Ativos por Mês (`HTTP 422 MAX_ACTIVE_PILLARS_EXCEEDED`).
final class MaxActivePillarsExceededFailure extends AppFailure {
  const MaxActivePillarsExceededFailure({
    super.message = 'Selecione apenas 3 pilares por mês!',
    super.errorCode = 'MAX_ACTIVE_PILLARS_EXCEEDED',
    super.statusCode = 422,
    super.details,
  });
}

/// Violação da Regra de Negócio RN02: Limite de Fadiga Mental > 80% atingido (`HTTP 422 MENTAL_FATIGUE_LIMIT_EXCEEDED`).
final class MentalFatigueBlockedFailure extends AppFailure {
  const MentalFatigueBlockedFailure({
    super.message = 'Limite de horas atingido, reagende a atividade.',
    super.errorCode = 'MENTAL_FATIGUE_LIMIT_EXCEEDED',
    super.statusCode = 422,
    super.details,
  });

  String? get dataAgendamento => details?['dataAgendamento'] as String?;
  int? get minutosUteis => (details?['minutosUteis'] as num?)?.toInt();
  int? get minutosComprometidos =>
      (details?['minutosComprometidos'] as num?)?.toInt();
  int? get percentualOcupacao =>
      (details?['percentualOcupacao'] as num?)?.toInt();
}

/// Recurso não encontrado (`HTTP 404 RESOURCE_NOT_FOUND`).
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'Recurso não encontrado.',
    super.errorCode = 'RESOURCE_NOT_FOUND',
    super.statusCode = 404,
    super.details,
  });
}

/// Falha de conectividade de rede ou timeout (`DioExceptionType.connectionTimeout`, etc.).
final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message =
        'Sem conexão com o servidor. Verifique sua internet e tente novamente.',
    super.errorCode = 'NETWORK_ERROR',
    super.statusCode,
    super.details,
  });
}

/// Erro interno do servidor ou resposta inesperada (`HTTP 5xx`).
final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message = 'Ocorreu um erro interno no servidor. Tente novamente.',
    super.errorCode = 'INTERNAL_SERVER_ERROR',
    super.statusCode = 500,
    super.details,
  });
}
