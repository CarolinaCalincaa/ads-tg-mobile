import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/core/network/api_exception_mapper.dart';
import 'package:produtividade_tcc/features/painel_dia/data/datasources/painel_remote_datasource.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/repositories/painel_repository.dart';

class PainelRepositoryImpl implements PainelRepository {
  PainelRepositoryImpl({required this.remoteDataSource});

  final PainelRemoteDataSource remoteDataSource;

  @override
  Future<Result<PainelDiaBundle>> getPainelDia(String data) async {
    try {
      final PainelDiaBundle bundle = await remoteDataSource.getPainelDia(data);
      return Success<PainelDiaBundle>(bundle);
    } catch (e) {
      return FailureResult<PainelDiaBundle>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<PainelSemanaBundle>> getPainelSemana(
    String dataReferencia,
  ) async {
    try {
      final PainelSemanaBundle bundle =
          await remoteDataSource.getPainelSemana(dataReferencia);
      return Success<PainelSemanaBundle>(bundle);
    } catch (e) {
      return FailureResult<PainelSemanaBundle>(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  }) async {
    try {
      final List<Map<String, dynamic>> dias =
          await remoteDataSource.getDiasLivres(
        dataOrigem: dataOrigem,
        duracaoMinutos: duracaoMinutos,
      );
      return Success(dias);
    } catch (e) {
      return FailureResult(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createTask(
    Map<String, dynamic> payload,
  ) async {
    try {
      final Map<String, dynamic> response =
          await remoteDataSource.createTask(payload);
      return Success(response);
    } catch (e) {
      return FailureResult(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateTask(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final Map<String, dynamic> response =
          await remoteDataSource.updateTask(id, payload);
      return Success(response);
    } catch (e) {
      return FailureResult(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id, bool concluido) async {
    try {
      await remoteDataSource.toggleTaskStatus(id, concluido);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> toggleHabitExecution(
    String id,
    String data,
    bool concluido,
  ) async {
    try {
      final Map<String, dynamic> response =
          await remoteDataSource.toggleHabitExecution(id, data, concluido);
      return Success<Map<String, dynamic>>(response);
    } catch (e) {
      return FailureResult<Map<String, dynamic>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createHabit(
    Map<String, dynamic> payload,
  ) async {
    try {
      final Map<String, dynamic> response =
          await remoteDataSource.createHabit(payload);
      return Success<Map<String, dynamic>>(response);
    } catch (e) {
      return FailureResult<Map<String, dynamic>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateHabit(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final Map<String, dynamic> response =
          await remoteDataSource.updateHabit(id, payload);
      return Success<Map<String, dynamic>>(response);
    } catch (e) {
      return FailureResult<Map<String, dynamic>>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      await remoteDataSource.deleteHabit(id);
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<List<ProjetoEntity>>> getProjetos({String? status}) async {
    try {
      final List<ProjetoEntity> list =
          await remoteDataSource.getProjetos(status: status);
      return Success(list);
    } catch (e) {
      return FailureResult(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<ProjetoEntity>> createProjeto(
    Map<String, dynamic> payload,
  ) async {
    try {
      final ProjetoEntity projeto =
          await remoteDataSource.createProjeto(payload);
      return Success<ProjetoEntity>(projeto);
    } catch (e) {
      return FailureResult<ProjetoEntity>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<List<ChecklistEntity>>> getChecklists({bool? ehModelo}) async {
    try {
      final List<ChecklistEntity> list =
          await remoteDataSource.getChecklists(ehModelo: ehModelo);
      return Success(list);
    } catch (e) {
      return FailureResult(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<ChecklistEntity>> createChecklist(
    Map<String, dynamic> payload,
  ) async {
    try {
      final ChecklistEntity checklist =
          await remoteDataSource.createChecklist(payload);
      return Success<ChecklistEntity>(checklist);
    } catch (e) {
      return FailureResult<ChecklistEntity>(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<ChecklistEntity>> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  }) async {
    try {
      final ChecklistEntity cloned = await remoteDataSource.cloneChecklist(
        idModelo: idModelo,
        idTarefa: idTarefa,
        idHabito: idHabito,
      );
      return Success<ChecklistEntity>(cloned);
    } catch (e) {
      return FailureResult<ChecklistEntity>(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<void>> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  }) async {
    try {
      await remoteDataSource.toggleChecklistItem(
        idChecklist: idChecklist,
        itemId: itemId,
        concluido: concluido,
      );
      return const Success<void>(null);
    } catch (e) {
      return FailureResult<void>(ApiExceptionMapper.map(e));
    }
  }

  @override
  Future<Result<ItemChecklistEntity>> addChecklistItem({
    required String idChecklist,
    required String descricao,
  }) async {
    try {
      final ItemChecklistEntity item = await remoteDataSource.addChecklistItem(
        idChecklist: idChecklist,
        descricao: descricao,
      );
      return Success<ItemChecklistEntity>(item);
    } catch (e) {
      return FailureResult<ItemChecklistEntity>(
        ApiExceptionMapper.map(e),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  ) async {
    try {
      final Map<String, dynamic> res =
          await remoteDataSource.registrarSessaoPomodoro(payload);
      return Success<Map<String, dynamic>>(res);
    } catch (e) {
      return FailureResult<Map<String, dynamic>>(
        ApiExceptionMapper.map(e),
      );
    }
  }
}

final Provider<PainelRepository> painelRepositoryProvider =
    Provider<PainelRepository>((Ref ref) {
  final PainelRemoteDataSource remote =
      ref.watch(painelRemoteDataSourceProvider);
  return PainelRepositoryImpl(remoteDataSource: remote);
});
