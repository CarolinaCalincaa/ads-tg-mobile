import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/features/pilares/data/datasources/pilares_remote_datasource.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';
import 'package:produtividade_tcc/features/pilares/domain/repositories/pilares_repository.dart';

class PilaresRepositoryImpl implements PilaresRepository {
  PilaresRepositoryImpl({required this.remoteDataSource});

  final PilaresRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<PilarEntity>>> getPilares() async {
    try {
      final List<PilarEntity> pilares = await remoteDataSource.getPilares();
      if (pilares.isEmpty) {
        return const Success<List<PilarEntity>>(PilarEntity.pilaresMestresCanonicos);
      }
      return Success<List<PilarEntity>>(pilares);
    } catch (e) {
      // Fallback gracioso para a lista canônica dos 7 pilares
      return const Success<List<PilarEntity>>(PilarEntity.pilaresMestresCanonicos);
    }
  }

  @override
  Future<Result<List<int>>> getPilaresAtivos(String mesAno) async {
    try {
      final List<int> ativos = await remoteDataSource.getPilaresAtivos(mesAno);
      return Success<List<int>>(ativos);
    } catch (e) {
      return FailureResult<List<int>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<List<int>>> setPilaresAtivos(
    String mesAno,
    List<int> idsPilares,
  ) async {
    // Validação de segurança local RN01 antes do envio
    if (idsPilares.length > 3) {
      return const FailureResult<List<int>>(
        MaxActivePillarsExceededFailure(
          message: 'Selecione apenas 3 pilares por mês!',
        ),
      );
    }

    try {
      final List<int> result = await remoteDataSource.setPilaresAtivos(
        mesAno,
        idsPilares,
      );
      return Success<List<int>>(result);
    } catch (e) {
      return FailureResult<List<int>>(ApiExceptionMapper.map(e));
    }
  }
}

final Provider<PilaresRepository> pilaresRepositoryProvider =
    Provider<PilaresRepository>((Ref ref) {
  final PilaresRemoteDataSource remote = ref.watch(pilaresRemoteDataSourceProvider);
  return PilaresRepositoryImpl(remoteDataSource: remote);
});
