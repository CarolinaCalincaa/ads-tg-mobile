import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/features/alertas/data/datasources/lembretes_remote_datasource.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';
import 'package:produtividade_tcc/features/alertas/domain/repositories/lembretes_repository.dart';

class LembretesRepositoryImpl implements LembretesRepository {
  LembretesRepositoryImpl({required this.remoteDataSource});

  final LembretesRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<LembreteConfigEntity>>> getLembretes() async {
    try {
      final List<LembreteConfigEntity> list =
          await remoteDataSource.getLembretes();
      if (list.isEmpty) {
        return const Success<List<LembreteConfigEntity>>(
          LembreteConfigEntity.padroes,
        );
      }
      return Success<List<LembreteConfigEntity>>(list);
    } catch (e) {
      // Fallback gracioso para os 4 lembretes padrão em offline/dev
      return const Success<List<LembreteConfigEntity>>(
        LembreteConfigEntity.padroes,
      );
    }
  }

  @override
  Future<Result<List<LembreteConfigEntity>>> saveLembretes(
    List<LembreteConfigEntity> configs,
  ) async {
    try {
      final List<LembreteConfigEntity> saved =
          await remoteDataSource.saveLembretes(configs);
      return Success<List<LembreteConfigEntity>>(saved);
    } catch (e) {
      return FailureResult<List<LembreteConfigEntity>>(ApiExceptionMapper.map(e));
    }
  }
}

final Provider<LembretesRepository> lembretesRepositoryProvider =
    Provider<LembretesRepository>((Ref ref) {
  final LembretesRemoteDataSource remote =
      ref.watch(lembretesRemoteDataSourceProvider);
  return LembretesRepositoryImpl(remoteDataSource: remote);
});
