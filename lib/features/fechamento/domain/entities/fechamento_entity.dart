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

  static const List<String> _nomesMeses = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Calcula o período civil (`dataInicio`, `dataFim`, `totalDiasCiclo` e `rotuloPeriodo`)
  /// para `SEMANAL` (Segunda a Domingo ISO) ou `MENSAL` (1º ao último dia do mês).
  static ({
    String dataInicio,
    String dataFim,
    int totalDiasCiclo,
    String rotuloPeriodo,
  }) calcularPeriodoLocal(String tipoCiclo, String dataRefStr) {
    final DateTime parsed =
        DateTime.tryParse(dataRefStr.split('T').first) ?? DateTime.now();
    final DateTime ref = DateTime.utc(parsed.year, parsed.month, parsed.day);

    if (tipoCiclo == 'MENSAL') {
      final DateTime inicio = DateTime.utc(ref.year, ref.month, 1);
      final DateTime fim = DateTime.utc(ref.year, ref.month + 1, 0);
      final String inicioStr = inicio.toIso8601String().substring(0, 10);
      final String fimStr = fim.toIso8601String().substring(0, 10);
      final String rotulo = formatarRotuloPeriodo(
        tipoCiclo: 'MENSAL',
        dataInicio: inicioStr,
        dataFim: fimStr,
      );
      return (
        dataInicio: inicioStr,
        dataFim: fimStr,
        totalDiasCiclo: fim.day,
        rotuloPeriodo: rotulo,
      );
    }

    // SEMANAL: Segunda (1) a Domingo (7)
    final int diffParaSegunda = ref.weekday - 1;
    final DateTime inicio = ref.subtract(Duration(days: diffParaSegunda));
    final DateTime fim = inicio.add(const Duration(days: 6));
    final String inicioStr = inicio.toIso8601String().substring(0, 10);
    final String fimStr = fim.toIso8601String().substring(0, 10);
    final String rotulo = formatarRotuloPeriodo(
      tipoCiclo: 'SEMANAL',
      dataInicio: inicioStr,
      dataFim: fimStr,
    );
    return (
      dataInicio: inicioStr,
      dataFim: fimStr,
      totalDiasCiclo: 7,
      rotuloPeriodo: rotulo,
    );
  }

  /// Gera um rótulo legível para o período do ciclo caso a API não envie `rotuloPeriodo`.
  static String formatarRotuloPeriodo({
    required String tipoCiclo,
    required String dataInicio,
    String? dataFim,
  }) {
    final DateTime? inicio = DateTime.tryParse(dataInicio.split('T').first);
    if (inicio == null) {
      return tipoCiclo == 'MENSAL' ? 'Ciclo Mensal' : 'Ciclo Semanal';
    }

    if (tipoCiclo == 'MENSAL') {
      final String nomeMes = _capitalize(_nomesMeses[inicio.month - 1]);
      return '$nomeMes / ${inicio.year}';
    }

    final DateTime fim = (dataFim != null && dataFim.isNotEmpty)
        ? (DateTime.tryParse(dataFim.split('T').first) ??
            inicio.add(const Duration(days: 6)))
        : inicio.add(const Duration(days: 6));

    final String d1 = inicio.day.toString().padLeft(2, '0');
    final String d2 = fim.day.toString().padLeft(2, '0');
    final String m2 = _nomesMeses[fim.month - 1];

    if (inicio.month == fim.month) {
      return '$d1 — $d2 de $m2';
    }
    final String m1 = _nomesMeses[inicio.month - 1];
    return '$d1 de $m1 — $d2 de $m2';
  }

  /// Cria uma prévia padrão válida para o ciclo atual caso o carregamento ainda esteja em andamento ou falhe.
  factory FechamentoPrevia.padrao({
    required String tipoCiclo,
    String? dataRef,
  }) {
    final String ref = (dataRef != null && dataRef.isNotEmpty)
        ? dataRef
        : DateTime.now().toIso8601String().substring(0, 10);
    final periodo = calcularPeriodoLocal(tipoCiclo, ref);

    return FechamentoPrevia(
      tipoCiclo: tipoCiclo,
      dataInicio: periodo.dataInicio,
      dataFim: periodo.dataFim,
      rotuloPeriodo: periodo.rotuloPeriodo,
      metricas: FechamentoMetricas(
        consistenciaPercentual: 0,
        habitosConcluidos: 0,
        habitosEsperados: 0,
        diasAtivos: 0,
        totalDiasCiclo: periodo.totalDiasCiclo,
        sequenciaAtualDias: 0,
      ),
    );
  }

  factory FechamentoPrevia.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> metricasJson =
        (json['metricas'] as Map<String, dynamic>?) ??
            (json['dadosConsolidados'] as Map<String, dynamic>?) ??
            json;

    final String tipoCiclo = json['tipoCiclo'] as String? ?? 'SEMANAL';
    final String dataRef = json['dataRef'] as String? ??
        DateTime.now().toIso8601String().substring(0, 10);

    String dataInicio = json['dataInicio'] as String? ??
        json['dataInicioCiclo'] as String? ??
        '';
    String dataFim =
        json['dataFim'] as String? ?? json['dataFimCiclo'] as String? ?? '';

    if (dataInicio.isEmpty || dataFim.isEmpty) {
      final periodoCalc = calcularPeriodoLocal(
        tipoCiclo,
        dataInicio.isNotEmpty ? dataInicio : dataRef,
      );
      if (dataInicio.isEmpty) dataInicio = periodoCalc.dataInicio;
      if (dataFim.isEmpty) dataFim = periodoCalc.dataFim;
    }

    String rotuloPeriodo = json['rotuloPeriodo'] as String? ?? '';
    if (rotuloPeriodo.isEmpty) {
      rotuloPeriodo = formatarRotuloPeriodo(
        tipoCiclo: tipoCiclo,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    }

    final Map<String, dynamic>? salvo =
        json['fechamentoSalvo'] as Map<String, dynamic>?;

    return FechamentoPrevia(
      tipoCiclo: tipoCiclo,
      dataInicio: dataInicio,
      dataFim: dataFim,
      rotuloPeriodo: rotuloPeriodo,
      metricas: FechamentoMetricas.fromJson(metricasJson),
      acaoFuncionouBem: json['acaoFuncionouBem'] as String? ??
          salvo?['acaoFuncionouBem'] as String?,
      oqueFazerDiferente: json['oqueFazerDiferente'] as String? ??
          salvo?['oqueFazerDiferente'] as String?,
      vitoriaReconhecer: json['vitoriaReconhecer'] as String? ??
          salvo?['vitoriaReconhecer'] as String?,
      fracassoAceitar: json['fracassoAceitar'] as String? ??
          salvo?['fracassoAceitar'] as String?,
      fechamentoExistenteId: json['fechamentoExistenteId'] as String? ??
          salvo?['id'] as String? ??
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

    final String tipoCiclo = json['tipoCiclo'] as String? ?? 'SEMANAL';
    final String dataInicio = json['dataInicio'] as String? ??
        json['dataInicioCiclo'] as String? ??
        '';
    String dataFim =
        json['dataFim'] as String? ?? json['dataFimCiclo'] as String? ?? '';

    if (dataInicio.isNotEmpty && dataFim.isEmpty) {
      final periodoCalc =
          FechamentoPrevia.calcularPeriodoLocal(tipoCiclo, dataInicio);
      dataFim = periodoCalc.dataFim;
    }

    String rotuloPeriodo = json['rotuloPeriodo'] as String? ??
        (metricasMap['rotuloPeriodo'] as String?) ??
        '';
    if (rotuloPeriodo.isEmpty && dataInicio.isNotEmpty) {
      rotuloPeriodo = FechamentoPrevia.formatarRotuloPeriodo(
        tipoCiclo: tipoCiclo,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    }

    return FechamentoEntity(
      id: json['id'] as String? ?? '',
      tipoCiclo: tipoCiclo,
      dataInicio: dataInicio,
      dataFim: dataFim,
      rotuloPeriodo: rotuloPeriodo,
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
      'dataInicioCiclo': dataInicio,
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
