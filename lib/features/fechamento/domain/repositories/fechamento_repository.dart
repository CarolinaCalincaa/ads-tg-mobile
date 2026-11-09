import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';

abstract interface class FechamentoRepository {
  /// Obtém a prévia calculada das métricas e respostas preenchidas previamente
  Future<Result<FechamentoPrevia>> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  });

  /// Envia ou atualiza a reflexão do ciclo com snapshot congelado de métricas
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
  });

  /// Lista o histórico cronológico de fechamentos passados (RF23)
  Future<Result<List<FechamentoEntity>>> getHistorico({
    String? tipoCiclo,
  });

  /// Obtém os detalhes completos de um fechamento por ID
  Future<Result<FechamentoEntity>> getFechamentoById(String id);
}
