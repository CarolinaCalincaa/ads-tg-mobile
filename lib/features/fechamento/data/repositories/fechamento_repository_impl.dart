import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/features/fechamento/data/datasources/fechamento_remote_datasource.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/domain/repositories/fechamento_repository.dart';

class FechamentoRepositoryImpl implements FechamentoRepository {
  FechamentoRepositoryImpl({required this.remoteDataSource});

  final FechamentoRemoteDataSource remoteDataSource;

  @override
  Future<Result<FechamentoPrevia>> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  }) async {
    try {
      final FechamentoPrevia previa = await remoteDataSource.getPrevia(
        tipoCiclo: tipoCiclo,
        dataRef: dataRef,
      );
      return Success<FechamentoPrevia>(previa);
    } catch (e) {
      return FailureResult<FechamentoPrevia>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<FechamentoEntity>> salvarFechamento({
    required String tipoCiclo,
    required String dataInicio,
    required String dataFim,
    required String rotuloPeriodo,
    required FechamentoMetricas metricas,
    String? acaoFuncionouBem,
    String? oqueFazerDiferente,
    String? vitoriaReconhecer,
    String? fracassoAceitar,
  }) async {
    try {
      final Map<String, dynamic> dadosConsolidados = <String, dynamic>{
        ...metricas.toJson(),
        if (dataFim.isNotEmpty) 'dataFim': dataFim,
        if (rotuloPeriodo.isNotEmpty) 'rotuloPeriodo': rotuloPeriodo,
      };

      final Map<String, dynamic> payload = <String, dynamic>{
        'tipoCiclo': tipoCiclo,
        'dataInicioCiclo': dataInicio,
        'dadosConsolidados': dadosConsolidados,
        'acaoFuncionouBem': ?acaoFuncionouBem,
        'oqueFazerDiferente': ?oqueFazerDiferente,
        'vitoriaReconhecer': ?vitoriaReconhecer,
        'fracassoAceitar': ?fracassoAceitar,
      };

      final FechamentoEntity entity =
          await remoteDataSource.salvarFechamento(payload);
      return Success<FechamentoEntity>(entity);
    } catch (e) {
      return FailureResult<FechamentoEntity>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<List<FechamentoEntity>>> getHistorico({
    String? tipoCiclo,
  }) async {
    try {
      final List<FechamentoEntity> lista =
          await remoteDataSource.getHistorico(tipoCiclo: tipoCiclo);
      return Success<List<FechamentoEntity>>(lista);
    } catch (e) {
      return FailureResult<List<FechamentoEntity>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<FechamentoEntity>> getFechamentoById(String id) async {
    try {
      final FechamentoEntity entity =
          await remoteDataSource.getFechamentoById(id);
      return Success<FechamentoEntity>(entity);
    } catch (e) {
      return FailureResult<FechamentoEntity>(ApiExceptionMapper.map(e));
    }
  }
}

final Provider<FechamentoRepository> fechamentoRepositoryProvider =
    Provider<FechamentoRepository>(
  (Ref ref) => FechamentoRepositoryImpl(
    remoteDataSource: ref.watch(fechamentoRemoteDataSourceProvider),
  ),
);
