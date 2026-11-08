import 'package:dio/dio.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';

/// Mapeador centralizado que converte [DioException] e envelopes JSON de erro
/// do `GlobalHttpExceptionFilter` do NestJS para a hierarquia tipada [AppFailure].
abstract final class ApiExceptionMapper {
  static AppFailure map(Object error) {
    if (error is AppFailure) {
      return error;
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    return const ServerFailure();
  }

  static AppFailure _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'A requisição foi cancelada.',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (exception.response == null) {
          return const NetworkFailure();
        }
        return _mapResponse(exception.response!);
      case DioExceptionType.badResponse:
        if (exception.response == null) {
          return const ServerFailure();
        }
        return _mapResponse(exception.response!);
    }
  }

  static AppFailure _mapResponse(Response<dynamic> response) {
    final int statusCode = response.statusCode ?? 500;
    final dynamic rawData = response.data;

    String? errorCode;
    String? message;
    Map<String, dynamic>? details;

    if (rawData is Map<String, dynamic>) {
      errorCode = rawData['errorCode'] as String?;
      final dynamic rawMessage = rawData['message'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        message = rawMessage;
      } else if (rawMessage is List && rawMessage.isNotEmpty) {
        message = rawMessage.join('; ');
      }
      final dynamic rawDetails = rawData['details'];
      if (rawDetails is Map<String, dynamic>) {
        details = rawDetails;
      }
    }

    switch (errorCode) {
      case 'MAX_ACTIVE_PILLARS_EXCEEDED':
        return MaxActivePillarsExceededFailure(
          message: message ?? 'Selecione apenas 3 pilares por mês!',
          statusCode: statusCode,
          details: details,
        );
      case 'MENTAL_FATIGUE_LIMIT_EXCEEDED':
        return MentalFatigueBlockedFailure(
          message: message ?? 'Limite de horas atingido, reagende a atividade.',
          statusCode: statusCode,
          details: details,
        );
      case 'VALIDATION_ERROR':
        return ValidationFailure(
          message:
              message ?? 'Dados inválidos. Verifique os campos informados.',
          statusCode: statusCode,
          details: details,
        );
      case 'INVALID_CREDENTIALS':
      case 'TOKEN_EXPIRED_OR_INVALID':
        return UnauthorizedFailure(
          message: message ?? 'Sessão expirada ou credenciais inválidas.',
          errorCode: errorCode,
          statusCode: statusCode,
          details: details,
        );
      case 'EMAIL_ALREADY_REGISTERED':
        return EmailAlreadyRegisteredFailure(
          message: message ?? 'Este e-mail já está cadastrado.',
          statusCode: statusCode,
          details: details,
        );
      case 'RESET_TOKEN_INVALID':
        return ResetTokenInvalidFailure(
          message: message ?? 'Código de recuperação inválido ou expirado.',
          statusCode: statusCode,
          details: details,
        );
      case 'RESOURCE_NOT_FOUND':
        return NotFoundFailure(
          message: message ?? 'Recurso não encontrado.',
          statusCode: statusCode,
          details: details,
        );
    }

    return switch (statusCode) {
      400 => ValidationFailure(
        message: message ?? 'Dados inválidos. Verifique os campos informados.',
        errorCode: errorCode ?? 'VALIDATION_ERROR',
        statusCode: statusCode,
        details: details,
      ),
      401 || 403 => UnauthorizedFailure(
        message: message ?? 'Sessão expirada ou credenciais inválidas.',
        errorCode: errorCode ?? 'TOKEN_EXPIRED_OR_INVALID',
        statusCode: statusCode,
        details: details,
      ),
      404 => NotFoundFailure(
        message: message ?? 'Recurso não encontrado.',
        errorCode: errorCode ?? 'RESOURCE_NOT_FOUND',
        statusCode: statusCode,
        details: details,
      ),
      409 => EmailAlreadyRegisteredFailure(
        message: message ?? 'Conflito de dados no registro.',
        errorCode: errorCode ?? 'EMAIL_ALREADY_REGISTERED',
        statusCode: statusCode,
        details: details,
      ),
      _ => ServerFailure(
        message:
            message ?? 'Ocorreu um erro interno no servidor. Tente novamente.',
        errorCode: errorCode ?? 'INTERNAL_SERVER_ERROR',
        statusCode: statusCode,
        details: details,
      ),
    };
  }
}
