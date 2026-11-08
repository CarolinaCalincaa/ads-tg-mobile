import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';

class DiaSemanaResumoEntity extends Equatable {
  const DiaSemanaResumoEntity({
    required this.data,
    required this.diaSemanaNome,
    required this.diaSemanaNumero,
    required this.capacidadeDia,
    required this.totalTarefas,
    required this.tarefasConcluidas,
    required this.totalHabitos,
    required this.habitosConcluidos,
  });

  factory DiaSemanaResumoEntity.fromJson(Map<String, dynamic> json) {
    return DiaSemanaResumoEntity(
      data: json['data'] as String,
      diaSemanaNome: json['diaSemanaNome'] as String? ?? '',
      diaSemanaNumero: json['diaSemanaNumero'] as int? ?? 1,
      capacidadeDia: CapacidadeDiaEntity.fromJson(
        json['capacidadeDia'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      totalTarefas: json['totalTarefas'] as int? ?? 0,
      tarefasConcluidas: json['tarefasConcluidas'] as int? ?? 0,
      totalHabitos: json['totalHabitos'] as int? ?? 0,
      habitosConcluidos: json['habitosConcluidos'] as int? ?? 0,
    );
  }

  final String data;
  final String diaSemanaNome;
  final int diaSemanaNumero;
  final CapacidadeDiaEntity capacidadeDia;
  final int totalTarefas;
  final int tarefasConcluidas;
  final int totalHabitos;
  final int habitosConcluidos;

  @override
  List<Object?> get props => <Object?>[
        data,
        diaSemanaNome,
        diaSemanaNumero,
        capacidadeDia,
        totalTarefas,
        tarefasConcluidas,
        totalHabitos,
        habitosConcluidos,
      ];
}

class PainelSemanaBundle extends Equatable {
  const PainelSemanaBundle({
    required this.dataReferencia,
    required this.inicioSemana,
    required this.fimSemana,
    required this.dias,
  });

  factory PainelSemanaBundle.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawDias = json['dias'] as List<dynamic>? ?? <dynamic>[];
    final List<DiaSemanaResumoEntity> dias = rawDias
        .map((d) => DiaSemanaResumoEntity.fromJson(d as Map<String, dynamic>))
        .toList();

    return PainelSemanaBundle(
      dataReferencia: json['dataReferencia'] as String,
      inicioSemana: json['inicioSemana'] as String,
      fimSemana: json['fimSemana'] as String,
      dias: dias,
    );
  }

  final String dataReferencia;
  final String inicioSemana;
  final String fimSemana;
  final List<DiaSemanaResumoEntity> dias;

  @override
  List<Object?> get props => <Object?>[dataReferencia, inicioSemana, fimSemana, dias];
}
