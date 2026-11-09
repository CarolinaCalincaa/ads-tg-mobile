import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';

abstract interface class PainelRepository {
  Future<Result<PainelDiaBundle>> getPainelDia(String data);
  Future<Result<PainelSemanaBundle>> getPainelSemana(String dataReferencia);
  Future<Result<List<Map<String, dynamic>>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  });

  Future<Result<Map<String, dynamic>>> createTask(Map<String, dynamic> payload);
  Future<Result<Map<String, dynamic>>> updateTask(
    String id,
    Map<String, dynamic> payload,
  );
  Future<Result<void>> deleteTask(String id);
  Future<Result<void>> toggleTaskStatus(String id, bool concluido);

  Future<Result<List<ProjetoEntity>>> getProjetos({String? status});
  Future<Result<ProjetoEntity>> createProjeto(Map<String, dynamic> payload);

  Future<Result<List<ChecklistEntity>>> getChecklists({bool? ehModelo});
  Future<Result<ChecklistEntity>> createChecklist(Map<String, dynamic> payload);
  Future<Result<ChecklistEntity>> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  });
  Future<Result<void>> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  });
  Future<Result<ItemChecklistEntity>> addChecklistItem({
    required String idChecklist,
    required String descricao,
  });

  Future<Result<Map<String, dynamic>>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  );
}
