import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/features/rotina/data/datasources/rotina_remote_datasource.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';
import 'package:produtividade_tcc/features/rotina/domain/repositories/rotina_repository.dart';

class RotinaRepositoryImpl implements RotinaRepository {
  RotinaRepositoryImpl({required this.remoteDataSource});

  final RotinaRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<RotinaTarefaEntity>>> getAllTarefas() async {
    try {
      final List<RotinaTarefaEntity> list =
          await remoteDataSource.getAllTarefas();
      return Success<List<RotinaTarefaEntity>>(list);
    } catch (e) {
      return FailureResult<List<RotinaTarefaEntity>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<List<RotinaHabitoEntity>>> getAllHabitos() async {
    try {
      final List<RotinaHabitoEntity> list =
          await remoteDataSource.getAllHabitos();
      return Success<List<RotinaHabitoEntity>>(list);
    } catch (e) {
      return FailureResult<List<RotinaHabitoEntity>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> toggleTarefaStatus(String id, bool concluido) async {
    try {
      await remoteDataSource.toggleTarefaStatus(id, concluido);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> deleteTarefa(String id) async {
    try {
      await remoteDataSource.deleteTarefa(id);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> toggleHabitoAtivo(String id, bool statusAtivo) async {
    try {
      await remoteDataSource.toggleHabitoAtivo(id, statusAtivo);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> deleteHabito(String id) async {
    try {
      await remoteDataSource.deleteHabito(id);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }
}

final Provider<RotinaRepository> rotinaRepositoryProvider =
    Provider<RotinaRepository>((Ref ref) {
  final RotinaRemoteDataSource remote =
      ref.watch(rotinaRemoteDataSourceProvider);
  return RotinaRepositoryImpl(remoteDataSource: remote);
});
