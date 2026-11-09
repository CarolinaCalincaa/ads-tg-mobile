import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';

abstract interface class LembretesRepository {
  Future<Result<List<LembreteConfigEntity>>> getLembretes();
  Future<Result<List<LembreteConfigEntity>>> saveLembretes(
    List<LembreteConfigEntity> configs,
  );
}
