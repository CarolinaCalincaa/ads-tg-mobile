import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';

/// Classe selada que representa o resultado de uma operação assíncrona ou de domínio.
///
/// Substitui o lançamento de exceções não tratadas na camada `domain`/`presentation`,
/// permitindo pattern matching exaustivo no Dart 3.
sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final T data) => data,
    FailureResult<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final AppFailure failure) => failure,
  };

  R fold<R>({
    required R Function(AppFailure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    return switch (this) {
      Success<T>(:final T data) => onSuccess(data),
      FailureResult<T>(:final AppFailure failure) => onFailure(failure),
    };
  }
}

/// Resultado de sucesso contendo o valor [data].
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

/// Resultado de falha contendo um [AppFailure] tipado.
final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
