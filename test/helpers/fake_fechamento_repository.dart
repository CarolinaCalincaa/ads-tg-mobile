import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/domain/repositories/fechamento_repository.dart';

class FakeFechamentoRepository implements FechamentoRepository {
  FakeFechamentoRepository({
    this.previaMock,
    List<FechamentoEntity>? historicoMock,
  }) : historico = historicoMock ?? <FechamentoEntity>[];

  FechamentoPrevia? previaMock;
  final List<FechamentoEntity> historico;
  final List<Map<String, dynamic>> chamadasSalvar = <Map<String, dynamic>>[];

  @override
  Future<Result<FechamentoPrevia>> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  }) async {
    return Success<FechamentoPrevia>(
      previaMock ??
          FechamentoPrevia(
            tipoCiclo: tipoCiclo,
            dataInicio: '2026-10-06',
            dataFim: '2026-10-12',
            rotuloPeriodo: '06 — 12 de outubro',
            metricas: const FechamentoMetricas(
              consistenciaPercentual: 74,
              habitosConcluidos: 18,
              habitosEsperados: 24,
              diasAtivos: 6,
              totalDiasCiclo: 7,
              sequenciaAtualDias: 5,
            ),
          ),
    );
  }

  @override
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
  }) async {
    final Map<String, dynamic> chamada = <String, dynamic>{
      'tipoCiclo': tipoCiclo,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'rotuloPeriodo': rotuloPeriodo,
      'metricas': metricas,
      'acaoFuncionouBem': acaoFuncionouBem,
      'oqueFazerDiferente': oqueFazerDiferente,
      'vitoriaReconhecer': vitoriaReconhecer,
      'fracassoAceitar': fracassoAceitar,
    };
    chamadasSalvar.add(chamada);

    final FechamentoEntity entity = FechamentoEntity(
      id: 'fechamento-123',
      tipoCiclo: tipoCiclo,
      dataInicio: dataInicio,
      dataFim: dataFim,
      rotuloPeriodo: rotuloPeriodo,
      dataFechamento: DateTime.now(),
      metricas: metricas,
      acaoFuncionouBem: acaoFuncionouBem,
      oqueFazerDiferente: oqueFazerDiferente,
      vitoriaReconhecer: vitoriaReconhecer,
      fracassoAceitar: fracassoAceitar,
    );
    historico.insert(0, entity);
    return Success<FechamentoEntity>(entity);
  }

  @override
  Future<Result<List<FechamentoEntity>>> getHistorico({
    String? tipoCiclo,
  }) async {
    if (tipoCiclo == null || tipoCiclo == 'TODOS') {
      return Success<List<FechamentoEntity>>(List.of(historico));
    }
    return Success<List<FechamentoEntity>>(
      historico.where((e) => e.tipoCiclo == tipoCiclo).toList(),
    );
  }

  @override
  Future<Result<FechamentoEntity>> getFechamentoById(String id) async {
    final FechamentoEntity item = historico.firstWhere(
      (e) => e.id == id,
      orElse: () => FechamentoEntity(
        id: id,
        tipoCiclo: 'SEMANAL',
        dataInicio: '2026-10-06',
        dataFim: '2026-10-12',
        rotuloPeriodo: '06 — 12 de outubro',
        dataFechamento: DateTime.now(),
        metricas: const FechamentoMetricas(
          consistenciaPercentual: 74,
          habitosConcluidos: 18,
          habitosEsperados: 24,
          diasAtivos: 6,
          totalDiasCiclo: 7,
          sequenciaAtualDias: 5,
        ),
      ),
    );
    return Success<FechamentoEntity>(item);
  }
}
