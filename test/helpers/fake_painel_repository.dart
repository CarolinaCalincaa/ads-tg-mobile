import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/repositories/painel_repository.dart';

class FakePainelRepository implements PainelRepository {
  PainelDiaBundle? diaBundle;
  PainelSemanaBundle? semanaBundle;

  FakePainelRepository({this.diaBundle, this.semanaBundle});

  @override
  Future<Result<PainelDiaBundle>> getPainelDia(String data) async {
    return Success<PainelDiaBundle>(
      diaBundle ?? PainelDiaBundle.vazio(data),
    );
  }

  @override
  Future<Result<PainelSemanaBundle>> getPainelSemana(
    String dataReferencia,
  ) async {
    return Success<PainelSemanaBundle>(
      semanaBundle ??
          PainelSemanaBundle(
            dataReferencia: dataReferencia,
            inicioSemana: dataReferencia,
            fimSemana: dataReferencia,
            dias: const [],
          ),
    );
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id, bool concluido) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> toggleHabitExecution(
    String id,
    String data,
    bool concluido,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': id,
      'concluido': concluido,
      'streakAtual': concluido ? 6 : 5,
    });
  }

  final List<Map<String, dynamic>> createdHabits = <Map<String, dynamic>>[];

  @override
  Future<Result<Map<String, dynamic>>> createHabit(
    Map<String, dynamic> payload,
  ) async {
    createdHabits.add(payload);
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': 'h-new',
      ...payload,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> updateHabit(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': id,
      ...payload,
    });
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  }) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<Map<String, dynamic>>> createTask(
    Map<String, dynamic> payload,
  ) async {
    return const Success<Map<String, dynamic>>(<String, dynamic>{'id': 't-created'});
  }

  @override
  Future<Result<Map<String, dynamic>>> updateTask(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return Success<Map<String, dynamic>>(<String, dynamic>{'id': id});
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  }) async {
    return const Success<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]);
  }

  @override
  Future<Result<List<ProjetoEntity>>> getProjetos({String? status}) async {
    return const Success<List<ProjetoEntity>>(<ProjetoEntity>[]);
  }

  @override
  Future<Result<ProjetoEntity>> createProjeto(
    Map<String, dynamic> payload,
  ) async {
    return const Success<ProjetoEntity>(
      ProjetoEntity(id: 'p-new', nome: 'Novo Projeto'),
    );
  }

  @override
  Future<Result<List<ChecklistEntity>>> getChecklists({bool? ehModelo}) async {
    return const Success<List<ChecklistEntity>>(<ChecklistEntity>[]);
  }

  @override
  Future<Result<ChecklistEntity>> createChecklist(
    Map<String, dynamic> payload,
  ) async {
    return const Success<ChecklistEntity>(
      ChecklistEntity(id: 'c-new', titulo: 'Novo Checklist'),
    );
  }

  @override
  Future<Result<ChecklistEntity>> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  }) async {
    return const Success<ChecklistEntity>(
      ChecklistEntity(id: 'c-clone', titulo: 'Clone'),
    );
  }

  @override
  Future<Result<ItemChecklistEntity>> addChecklistItem({
    required String idChecklist,
    required String descricao,
  }) async {
    return Success<ItemChecklistEntity>(
      ItemChecklistEntity(
        id: 'it-new',
        idChecklist: idChecklist,
        descricao: descricao,
        concluido: false,
      ),
    );
  }

  final List<Map<String, dynamic>> sessaoPomodoroRegistros =
      <Map<String, dynamic>>[];

  @override
  Future<Result<Map<String, dynamic>>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  ) async {
    sessaoPomodoroRegistros.add(payload);
    return Success<Map<String, dynamic>>(<String, dynamic>{
      'id': 'pomodoro-${sessaoPomodoroRegistros.length}',
      ...payload,
    });
  }
}
