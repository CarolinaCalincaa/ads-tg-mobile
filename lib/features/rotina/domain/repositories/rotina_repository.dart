import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';

abstract interface class RotinaRepository {
  Future<Result<List<RotinaTarefaEntity>>> getAllTarefas();
  Future<Result<List<RotinaHabitoEntity>>> getAllHabitos();
  Future<Result<void>> toggleTarefaStatus(String id, bool concluido);
  Future<Result<void>> deleteTarefa(String id);
  Future<Result<void>> toggleHabitoAtivo(String id, bool statusAtivo);
  Future<Result<void>> deleteHabito(String id);
}
