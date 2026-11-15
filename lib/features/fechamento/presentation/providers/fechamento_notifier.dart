import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/error/app_failure.dart';
import 'package:produtividade_tcc/core/error/result.dart';
import 'package:produtividade_tcc/features/fechamento/data/repositories/fechamento_repository_impl.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';
import 'package:produtividade_tcc/features/fechamento/domain/repositories/fechamento_repository.dart';

enum FechamentoStatus { initial, loading, loaded, saving, saved, error }

class FechamentoState {
  const FechamentoState({
    this.status = FechamentoStatus.initial,
    this.tipoCiclo = 'SEMANAL',
    this.dataRef = '',
    this.previa,
    this.fechamentoSalvo,
    this.historico = const <FechamentoEntity>[],
    this.filtroHistorico = 'TODOS',
    this.errorMessage,
  });

  final FechamentoStatus status;
  final String tipoCiclo; // 'SEMANAL' | 'MENSAL'
  final String dataRef;
  final FechamentoPrevia? previa;
  final FechamentoEntity? fechamentoSalvo;
  final List<FechamentoEntity> historico;
  final String filtroHistorico; // 'TODOS' | 'SEMANAL' | 'MENSAL'
  final String? errorMessage;

  bool get isLoading =>
      status == FechamentoStatus.loading || status == FechamentoStatus.saving;

  FechamentoState copyWith({
    FechamentoStatus? status,
    String? tipoCiclo,
    String? dataRef,
    FechamentoPrevia? previa,
    FechamentoEntity? fechamentoSalvo,
    List<FechamentoEntity>? historico,
    String? filtroHistorico,
    String? errorMessage,
  }) {
    return FechamentoState(
      status: status ?? this.status,
      tipoCiclo: tipoCiclo ?? this.tipoCiclo,
      dataRef: dataRef ?? this.dataRef,
      previa: previa ?? this.previa,
      fechamentoSalvo: fechamentoSalvo ?? this.fechamentoSalvo,
      historico: historico ?? this.historico,
      filtroHistorico: filtroHistorico ?? this.filtroHistorico,
      errorMessage: errorMessage,
    );
  }
}

class FechamentoNotifier extends Notifier<FechamentoState> {
  @override
  FechamentoState build() {
    final String hoje = DateTime.now().toIso8601String().substring(0, 10);
    return FechamentoState(
      tipoCiclo: 'SEMANAL',
      dataRef: hoje,
      previa: FechamentoPrevia.padrao(
        tipoCiclo: 'SEMANAL',
        dataRef: hoje,
      ),
    );
  }

  FechamentoRepository get _repository =>
      ref.read(fechamentoRepositoryProvider);

  Future<void> carregarPrevia({
    String? tipoCiclo,
    String? dataRef,
  }) async {
    final String ciclo = tipoCiclo ?? state.tipoCiclo;
    final String data = dataRef ??
        (state.dataRef.isNotEmpty
            ? state.dataRef
            : DateTime.now().toIso8601String().substring(0, 10));

    final FechamentoPrevia previaFallback =
        (state.previa != null &&
                state.previa!.tipoCiclo == ciclo &&
                state.dataRef == data)
            ? state.previa!
            : FechamentoPrevia.padrao(tipoCiclo: ciclo, dataRef: data);

    state = state.copyWith(
      status: FechamentoStatus.loading,
      tipoCiclo: ciclo,
      dataRef: data,
      previa: previaFallback,
    );

    final Result<FechamentoPrevia> result = await _repository.getPrevia(
      tipoCiclo: ciclo,
      dataRef: data,
    );

    result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: FechamentoStatus.error,
          previa: state.previa ?? previaFallback,
          errorMessage: failure.message,
        );
      },
      onSuccess: (FechamentoPrevia previa) {
        state = state.copyWith(
          status: FechamentoStatus.loaded,
          previa: previa,
        );
      },
    );
  }

  void alternarTipoCiclo(String novoCiclo) {
    if (state.tipoCiclo != novoCiclo) {
      carregarPrevia(tipoCiclo: novoCiclo);
    }
  }

  Future<bool> salvarFechamento({
    required String acaoFuncionouBem,
    required String oqueFazerDiferente,
    required String vitoriaReconhecer,
    required String fracassoAceitar,
  }) async {
    final FechamentoPrevia previa = state.previa ??
        FechamentoPrevia.padrao(
          tipoCiclo: state.tipoCiclo,
          dataRef: state.dataRef.isNotEmpty ? state.dataRef : null,
        );

    state = state.copyWith(
      status: FechamentoStatus.saving,
      previa: previa,
    );

    final Result<FechamentoEntity> result = await _repository.salvarFechamento(
      tipoCiclo: state.tipoCiclo,
      dataInicio: previa.dataInicio,
      dataFim: previa.dataFim,
      rotuloPeriodo: previa.rotuloPeriodo,
      metricas: previa.metricas,
      acaoFuncionouBem: acaoFuncionouBem,
      oqueFazerDiferente: oqueFazerDiferente,
      vitoriaReconhecer: vitoriaReconhecer,
      fracassoAceitar: fracassoAceitar,
    );

    return result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: FechamentoStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      onSuccess: (FechamentoEntity salvo) {
        state = state.copyWith(
          status: FechamentoStatus.saved,
          fechamentoSalvo: salvo,
        );
        return true;
      },
    );
  }

  Future<void> carregarHistorico({String? filtro}) async {
    final String f = filtro ?? state.filtroHistorico;
    state = state.copyWith(
      status: FechamentoStatus.loading,
      filtroHistorico: f,
    );

    final Result<List<FechamentoEntity>> result =
        await _repository.getHistorico(tipoCiclo: f);

    result.fold(
      onFailure: (AppFailure failure) {
        state = state.copyWith(
          status: FechamentoStatus.error,
          errorMessage: failure.message,
        );
      },
      onSuccess: (List<FechamentoEntity> lista) {
        state = state.copyWith(
          status: FechamentoStatus.loaded,
          historico: lista,
        );
      },
    );
  }
}

final NotifierProvider<FechamentoNotifier, FechamentoState>
    fechamentoNotifierProvider =
    NotifierProvider<FechamentoNotifier, FechamentoState>(
  FechamentoNotifier.new,
);
