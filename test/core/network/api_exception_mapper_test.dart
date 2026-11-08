import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtividade_tcc/core/config/env_config.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';

DioException _buildBadResponse({
  required int statusCode,
  required Map<String, dynamic> data,
}) {
  final RequestOptions requestOptions = RequestOptions(path: '/api/v1/test');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  group('DioClient & Result<T> (E01-T03 / E01-T05)', () {
    test('DioClient configures EnvConfig.apiBaseUrl and 5s timeouts', () {
      final DioClient client = DioClient();
      expect(client.instance.options.baseUrl, EnvConfig.apiBaseUrl);
      expect(
        client.instance.options.connectTimeout,
        const Duration(seconds: 5),
      );
      expect(
        client.instance.options.receiveTimeout,
        const Duration(seconds: 5),
      );
    });

    test('Result<T> supports Success and FailureResult with fold', () {
      const Result<int> success = Success<int>(42);
      const Result<int> failure = FailureResult<int>(
        MaxActivePillarsExceededFailure(),
      );

      expect(success.isSuccess, isTrue);
      expect(success.dataOrNull, 42);
      expect(
        success.fold(
          onFailure: (_) => 'erro',
          onSuccess: (int v) => 'ok:$v',
        ),
        'ok:42',
      );

      expect(failure.isFailure, isTrue);
      expect(failure.failureOrNull, isA<MaxActivePillarsExceededFailure>());
    });
  });

  group('ApiExceptionMapper (E01-T05)', () {
    test(
      'maps MAX_ACTIVE_PILLARS_EXCEEDED (HTTP 422 - RN01) to MaxActivePillarsExceededFailure',
      () {
        final DioException exception = _buildBadResponse(
          statusCode: 422,
          data: <String, dynamic>{
            'statusCode': 422,
            'errorCode': 'MAX_ACTIVE_PILLARS_EXCEEDED',
            'message': 'Selecione apenas 3 pilares por mês!',
            'details': <String, dynamic>{'mesAno': '2026-10-01'},
          },
        );

        final AppFailure failure = ApiExceptionMapper.map(exception);

        expect(failure, isA<MaxActivePillarsExceededFailure>());
        expect(failure.message, 'Selecione apenas 3 pilares por mês!');
        expect(failure.errorCode, 'MAX_ACTIVE_PILLARS_EXCEEDED');
        expect(failure.statusCode, 422);
      },
    );

    test(
      'maps MENTAL_FATIGUE_LIMIT_EXCEEDED (HTTP 422 - RN02) to MentalFatigueBlockedFailure with details',
      () {
        final DioException exception = _buildBadResponse(
          statusCode: 422,
          data: <String, dynamic>{
            'statusCode': 422,
            'errorCode': 'MENTAL_FATIGUE_LIMIT_EXCEEDED',
            'message': 'Limite de horas atingido, reagende a atividade.',
            'details': <String, dynamic>{
              'dataAgendamento': '2026-10-15',
              'minutosUteis': 960,
              'minutosComprometidos': 790,
              'percentualOcupacao': 82,
            },
          },
        );

        final AppFailure failure = ApiExceptionMapper.map(exception);

        expect(failure, isA<MentalFatigueBlockedFailure>());
        final MentalFatigueBlockedFailure fatigueFailure =
            failure as MentalFatigueBlockedFailure;
        expect(
          fatigueFailure.message,
          'Limite de horas atingido, reagende a atividade.',
        );
        expect(fatigueFailure.dataAgendamento, '2026-10-15');
        expect(fatigueFailure.minutosUteis, 960);
        expect(fatigueFailure.minutosComprometidos, 790);
        expect(fatigueFailure.percentualOcupacao, 82);
      },
    );

    test('maps canonical auth, validation, conflict and not-found errorCodes', () {
      expect(
        ApiExceptionMapper.map(
          _buildBadResponse(
            statusCode: 400,
            data: <String, dynamic>{
              'errorCode': 'VALIDATION_ERROR',
              'message': <String>['Campo nome obrigatório'],
            },
          ),
        ),
        isA<ValidationFailure>(),
      );

      expect(
        ApiExceptionMapper.map(
          _buildBadResponse(
            statusCode: 401,
            data: <String, dynamic>{
              'errorCode': 'INVALID_CREDENTIALS',
              'message': 'Credenciais inválidas.',
            },
          ),
        ),
        isA<UnauthorizedFailure>(),
      );

      expect(
        ApiExceptionMapper.map(
          _buildBadResponse(
            statusCode: 409,
            data: <String, dynamic>{
              'errorCode': 'EMAIL_ALREADY_REGISTERED',
              'message': 'Este e-mail já está cadastrado.',
            },
          ),
        ),
        isA<EmailAlreadyRegisteredFailure>(),
      );

      expect(
        ApiExceptionMapper.map(
          _buildBadResponse(
            statusCode: 400,
            data: <String, dynamic>{
              'errorCode': 'RESET_TOKEN_INVALID',
            },
          ),
        ),
        isA<ResetTokenInvalidFailure>(),
      );

      expect(
        ApiExceptionMapper.map(
          _buildBadResponse(
            statusCode: 404,
            data: <String, dynamic>{
              'errorCode': 'RESOURCE_NOT_FOUND',
            },
          ),
        ),
        isA<NotFoundFailure>(),
      );
    });

    test('maps connection timeout and connectionError to NetworkFailure', () {
      final DioException timeoutException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/health'),
        type: DioExceptionType.connectionTimeout,
      );

      final AppFailure failure = ApiExceptionMapper.map(timeoutException);
      expect(failure, isA<NetworkFailure>());
      expect(failure.errorCode, 'NETWORK_ERROR');
    });
  });
}
