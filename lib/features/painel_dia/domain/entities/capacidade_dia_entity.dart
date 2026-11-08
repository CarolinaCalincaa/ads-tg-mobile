import 'package:equatable/equatable.dart';

enum NivelFadiga {
  equilibrado,
  atencao,
  riscoFadiga,
}

class CapacidadeDiaEntity extends Equatable {
  const CapacidadeDiaEntity({
    required this.horasSonoDiarias,
    required this.minutosUteis,
    required this.limiteFadigaMinutos,
    required this.minutosTarefas,
    required this.minutosHabitos,
    required this.minutosComprometidos,
    required this.percentualOcupacao,
    required this.nivel,
    required this.emAlertaFadiga,
    required this.novosAgendamentosBloqueados,
  });

  const CapacidadeDiaEntity.padrao()
      : this(
          horasSonoDiarias: 8,
          minutosUteis: 960,
          limiteFadigaMinutos: 768,
          minutosTarefas: 0,
          minutosHabitos: 0,
          minutosComprometidos: 0,
          percentualOcupacao: 0,
          nivel: NivelFadiga.equilibrado,
          emAlertaFadiga: false,
          novosAgendamentosBloqueados: false,
        );

  factory CapacidadeDiaEntity.fromJson(Map<String, dynamic> json) {
    final String nivelStr = (json['nivel'] as String?)?.toUpperCase() ?? 'EQUILIBRADO';
    final NivelFadiga nivel = switch (nivelStr) {
      'RISCO_FADIGA' => NivelFadiga.riscoFadiga,
      'ATENCAO' => NivelFadiga.atencao,
      _ => NivelFadiga.equilibrado,
    };

    return CapacidadeDiaEntity(
      horasSonoDiarias: json['horasSonoDiarias'] as int? ?? 8,
      minutosUteis: json['minutosUteis'] as int? ?? 960,
      limiteFadigaMinutos: json['limiteFadigaMinutos'] as int? ?? 768,
      minutosTarefas: json['minutosTarefas'] as int? ?? 0,
      minutosHabitos: json['minutosHabitos'] as int? ?? 0,
      minutosComprometidos: json['minutosComprometidos'] as int? ?? 0,
      percentualOcupacao: json['percentualOcupacao'] as int? ?? 0,
      nivel: nivel,
      emAlertaFadiga: json['emAlertaFadiga'] as bool? ?? false,
      novosAgendamentosBloqueados: json['novosAgendamentosBloqueados'] as bool? ?? false,
    );
  }

  final int horasSonoDiarias;
  final int minutosUteis;
  final int limiteFadigaMinutos;
  final int minutosTarefas;
  final int minutosHabitos;
  final int minutosComprometidos;
  final int percentualOcupacao;
  final NivelFadiga nivel;
  final bool emAlertaFadiga;
  final bool novosAgendamentosBloqueados;

  @override
  List<Object?> get props => <Object?>[
        horasSonoDiarias,
        minutosUteis,
        limiteFadigaMinutos,
        minutosTarefas,
        minutosHabitos,
        minutosComprometidos,
        percentualOcupacao,
        nivel,
        emAlertaFadiga,
        novosAgendamentosBloqueados,
      ];
}
