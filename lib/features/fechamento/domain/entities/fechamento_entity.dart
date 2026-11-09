class FechamentoMetricas {
  const FechamentoMetricas({
    required this.consistenciaPercentual,
    required this.habitosConcluidos,
    required this.habitosEsperados,
    required this.diasAtivos,
    required this.totalDiasCiclo,
    required this.sequenciaAtualDias,
  });

  final int consistenciaPercentual;
  final int habitosConcluidos;
  final int habitosEsperados;
  final int diasAtivos;
  final int totalDiasCiclo;
  final int sequenciaAtualDias;

  factory FechamentoMetricas.fromJson(Map<String, dynamic> json) {
    return FechamentoMetricas(
      consistenciaPercentual:
          (json['consistenciaPercentual'] as num?)?.toInt() ?? 0,
      habitosConcluidos: (json['habitosConcluidos'] as num?)?.toInt() ?? 0,
      habitosEsperados: (json['habitosEsperados'] as num?)?.toInt() ?? 0,
      diasAtivos: (json['diasAtivos'] as num?)?.toInt() ?? 0,
      totalDiasCiclo: (json['totalDiasCiclo'] as num?)?.toInt() ?? 7,
      sequenciaAtualDias: (json['sequenciaAtualDias'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'consistenciaPercentual': consistenciaPercentual,
      'habitosConcluidos': habitosConcluidos,
      'habitosEsperados': habitosEsperados,
      'diasAtivos': diasAtivos,
      'totalDiasCiclo': totalDiasCiclo,
      'sequenciaAtualDias': sequenciaAtualDias,
    };
  }

  FechamentoMetricas copyWith({
    int? consistenciaPercentual,
    int? habitosConcluidos,
    int? habitosEsperados,
    int? diasAtivos,
    int? totalDiasCiclo,
    int? sequenciaAtualDias,
  }) {
    return FechamentoMetricas(
      consistenciaPercentual:
          consistenciaPercentual ?? this.consistenciaPercentual,
      habitosConcluidos: habitosConcluidos ?? this.habitosConcluidos,
      habitosEsperados: habitosEsperados ?? this.habitosEsperados,
      diasAtivos: diasAtivos ?? this.diasAtivos,
      totalDiasCiclo: totalDiasCiclo ?? this.totalDiasCiclo,
      sequenciaAtualDias: sequenciaAtualDias ?? this.sequenciaAtualDias,
    );
  }
}

class FechamentoPrevia {
  const FechamentoPrevia({
    required this.tipoCiclo,
    required this.dataInicio,
    required this.dataFim,
    required this.rotuloPeriodo,
    required this.metricas,
    this.acaoFuncionouBem,
    this.oqueFazerDiferente,
    this.vitoriaReconhecer,
    this.fracassoAceitar,
    this.fechamentoExistenteId,
  });

  final String tipoCiclo; // 'SEMANAL' | 'MENSAL'
  final String dataInicio; // YYYY-MM-DD
  final String dataFim; // YYYY-MM-DD
  final String rotuloPeriodo; // ex: '06 — 12 de outubro'
  final FechamentoMetricas metricas;
  final String? acaoFuncionouBem;
  final String? oqueFazerDiferente;
  final String? vitoriaReconhecer;
  final String? fracassoAceitar;
  final String? fechamentoExistenteId;

  factory FechamentoPrevia.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> metricasJson =
        (json['metricas'] as Map<String, dynamic>?) ?? json;

    return FechamentoPrevia(
      tipoCiclo: json['tipoCiclo'] as String? ?? 'SEMANAL',
      dataInicio: json['dataInicio'] as String? ?? '',
      dataFim: json['dataFim'] as String? ?? '',
      rotuloPeriodo: json['rotuloPeriodo'] as String? ?? '',
      metricas: FechamentoMetricas.fromJson(metricasJson),
      acaoFuncionouBem: json['acaoFuncionouBem'] as String?,
      oqueFazerDiferente: json['oqueFazerDiferente'] as String?,
      vitoriaReconhecer: json['vitoriaReconhecer'] as String?,
      fracassoAceitar: json['fracassoAceitar'] as String?,
      fechamentoExistenteId: json['fechamentoExistenteId'] as String? ??
          json['id'] as String?,
    );
  }
}

class FechamentoEntity {
  const FechamentoEntity({
    required this.id,
    required this.tipoCiclo,
    required this.dataInicio,
    required this.dataFim,
    required this.rotuloPeriodo,
    required this.dataFechamento,
    required this.metricas,
    this.acaoFuncionouBem,
    this.oqueFazerDiferente,
    this.vitoriaReconhecer,
    this.fracassoAceitar,
    this.insightIa,
  });

  final String id;
  final String tipoCiclo; // 'SEMANAL' | 'MENSAL'
  final String dataInicio; // YYYY-MM-DD
  final String dataFim; // YYYY-MM-DD
  final String rotuloPeriodo;
  final DateTime dataFechamento;
  final FechamentoMetricas metricas;
  final String? acaoFuncionouBem;
  final String? oqueFazerDiferente;
  final String? vitoriaReconhecer;
  final String? fracassoAceitar;
  final String? insightIa;

  factory FechamentoEntity.fromJson(Map<String, dynamic> json) {
    final dynamic dadosConsolidados = json['dadosConsolidados'];
    Map<String, dynamic> metricasMap = <String, dynamic>{};
    if (dadosConsolidados is Map<String, dynamic>) {
      metricasMap = dadosConsolidados;
    } else if (json['metricas'] is Map<String, dynamic>) {
      metricasMap = json['metricas'] as Map<String, dynamic>;
    } else {
      metricasMap = json;
    }

    return FechamentoEntity(
      id: json['id'] as String? ?? '',
      tipoCiclo: json['tipoCiclo'] as String? ?? 'SEMANAL',
      dataInicio: json['dataInicio'] as String? ?? '',
      dataFim: json['dataFim'] as String? ?? '',
      rotuloPeriodo: json['rotuloPeriodo'] as String? ?? '',
      dataFechamento: json['dataFechamento'] != null
          ? DateTime.tryParse(json['dataFechamento'].toString()) ??
              DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now()
              : DateTime.now()),
      metricas: FechamentoMetricas.fromJson(metricasMap),
      acaoFuncionouBem: json['acaoFuncionouBem'] as String?,
      oqueFazerDiferente: json['oqueFazerDiferente'] as String?,
      vitoriaReconhecer: json['vitoriaReconhecer'] as String?,
      fracassoAceitar: json['fracassoAceitar'] as String?,
      insightIa: json['insightIa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tipoCiclo': tipoCiclo,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'rotuloPeriodo': rotuloPeriodo,
      'dataFechamento': dataFechamento.toIso8601String(),
      'dadosConsolidados': metricas.toJson(),
      'acaoFuncionouBem': acaoFuncionouBem,
      'oqueFazerDiferente': oqueFazerDiferente,
      'vitoriaReconhecer': vitoriaReconhecer,
      'fracassoAceitar': fracassoAceitar,
      'insightIa': insightIa,
    };
  }
}
