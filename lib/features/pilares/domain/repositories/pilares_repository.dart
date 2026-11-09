import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';

abstract interface class PilaresRepository {
  /// Retorna os 7 Pilares Mestres (`GET /api/v1/pilares`).
  Future<Result<List<PilarEntity>>> getPilares();

  /// Retorna os IDs dos pilares ativos no mês especificado (`GET /api/v1/pilares/ativos?mesAno=YYYY-MM-01`).
  Future<Result<List<int>>> getPilaresAtivos(String mesAno);

  /// Atualiza os pilares ativos no mês (`PUT /api/v1/pilares/ativos/:mesAno`).
  ///
  /// Dispara [MaxActivePillarsExceededFailure] se `idsPilares.length > 3` (RN01).
  Future<Result<List<int>>> setPilaresAtivos(String mesAno, List<int> idsPilares);
}
