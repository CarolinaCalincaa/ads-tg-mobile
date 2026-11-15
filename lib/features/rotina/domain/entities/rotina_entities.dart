import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';

/// Entidade que representa uma Tarefa ou Compromisso na visão de Centro de Controle (Rotina).
class RotinaTarefaEntity extends Equatable {
  const RotinaTarefaEntity({
    required this.id,
    required this.tipoItem,
    required this.nome,
    required this.duracaoEstimadaMinutos,
    required this.prioridade,
    required this.indicadorDependencia,
    required this.dataAgendamento,
    required this.status,
    required this.concluido,
    required this.pilar,
    this.descricao,
    this.horarioInicio,
    this.concluidaEm,
    this.pomodorosConcluidos = 0,
    this.projeto,
    this.checklists = const <ChecklistEntity>[],
  });

  factory RotinaTarefaEntity.fromJson(Map<String, dynamic> json) {
    final String prioridadeStr = (json['prioridade'] as String?) ?? 'PRIORIDADE';
    final TaskPriority prioridade = TaskPriority.fromApiCode(prioridadeStr);

    final List<dynamic> rawChecklists =
        json['checklists'] as List<dynamic>? ?? <dynamic>[];
    final List<ChecklistEntity> checklists = rawChecklists
        .map((c) => ChecklistEntity.fromJson(c as Map<String, dynamic>))
        .toList();

    final String status = json['status'] as String? ?? 'PENDENTE';
    final bool concluido =
        (json['concluido'] as bool?) ?? (status.toUpperCase() == 'CONCLUIDA');

    return RotinaTarefaEntity(
      id: json['id'] as String? ?? '',
      tipoItem: json['tipoItem'] as String? ?? 'TAREFA',
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String?,
      duracaoEstimadaMinutos: json['duracaoEstimadaMinutos'] as int? ?? 30,
      prioridade: prioridade,
      indicadorDependencia:
          json['indicadorDependencia'] as String? ?? 'MINHAS_ACOES',
      dataAgendamento: json['dataAgendamento'] as String? ?? '',
      horarioInicio: json['horarioInicio'] as String?,
      status: status,
      concluido: concluido,
      concluidaEm: json['concluidaEm'] as String?,
      pomodorosConcluidos: json['pomodorosConcluidos'] as int? ?? 0,
      pilar: PilarResumoEntity.fromJson(
        json['pilar'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      projeto: json['projeto'] != null
          ? ProjetoEntity.fromJson(json['projeto'] as Map<String, dynamic>)
          : null,
      checklists: checklists,
    );
  }

  final String id;
  final String tipoItem; // 'TAREFA' | 'COMPROMISSO'
  final String nome;
  final String? descricao;
  final int duracaoEstimadaMinutos;
  final TaskPriority prioridade;
  final String indicadorDependencia; // 'MINHAS_ACOES' | 'EM_ESPERA'
  final String dataAgendamento; // 'YYYY-MM-DD'
  final String? horarioInicio; // 'HH:mm'
  final String status; // 'PENDENTE' | 'CONCLUIDA' | 'CANCELADA'
  final bool concluido;
  final String? concluidaEm;
  final int pomodorosConcluidos;
  final PilarResumoEntity pilar;
  final ProjetoEntity? projeto;
  final List<ChecklistEntity> checklists;

  bool get ehCompromisso => tipoItem == 'COMPROMISSO';
  bool get ehEmEspera => indicadorDependencia == 'EM_ESPERA';

  int get totalChecklistItens =>
      checklists.fold(0, (sum, c) => sum + c.totalItens);
  int get concluidosChecklistItens =>
      checklists.fold(0, (sum, c) => sum + c.itensConcluidos);

  TimelineItemEntity toTimelineItem() {
    return TimelineItemEntity(
      id: id,
      natureza: NaturezaItem.tarefa,
      tipoItem: tipoItem,
      horario: horarioInicio,
      nome: nome,
      descricao: descricao,
      duracaoEstimadaMinutos: duracaoEstimadaMinutos,
      prioridade: prioridade,
      indicadorDependencia: indicadorDependencia,
      concluido: concluido,
      concluidaEm: concluidaEm,
      pomodorosConcluidos: pomodorosConcluidos,
      pilar: pilar,
      projeto: projeto,
      checklists: checklists,
    );
  }

  RotinaTarefaEntity copyWith({
    String? id,
    String? tipoItem,
    String? nome,
    String? descricao,
    int? duracaoEstimadaMinutos,
    TaskPriority? prioridade,
    String? indicadorDependencia,
    String? dataAgendamento,
    String? horarioInicio,
    String? status,
    bool? concluido,
    String? concluidaEm,
    int? pomodorosConcluidos,
    PilarResumoEntity? pilar,
    ProjetoEntity? projeto,
    List<ChecklistEntity>? checklists,
  }) {
    return RotinaTarefaEntity(
      id: id ?? this.id,
      tipoItem: tipoItem ?? this.tipoItem,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      duracaoEstimadaMinutos:
          duracaoEstimadaMinutos ?? this.duracaoEstimadaMinutos,
      prioridade: prioridade ?? this.prioridade,
      indicadorDependencia: indicadorDependencia ?? this.indicadorDependencia,
      dataAgendamento: dataAgendamento ?? this.dataAgendamento,
      horarioInicio: horarioInicio ?? this.horarioInicio,
      status: status ?? this.status,
      concluido: concluido ?? this.concluido,
      concluidaEm: concluidaEm ?? this.concluidaEm,
      pomodorosConcluidos: pomodorosConcluidos ?? this.pomodorosConcluidos,
      pilar: pilar ?? this.pilar,
      projeto: projeto ?? this.projeto,
      checklists: checklists ?? this.checklists,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        tipoItem,
        nome,
        descricao,
        duracaoEstimadaMinutos,
        prioridade,
        indicadorDependencia,
        dataAgendamento,
        horarioInicio,
        status,
        concluido,
        concluidaEm,
        pomodorosConcluidos,
        pilar,
        projeto,
        checklists,
      ];
}

/// Entidade que representa um Hábito Recorrente na visão de Centro de Controle (Rotina).
class RotinaHabitoEntity extends Equatable {
  const RotinaHabitoEntity({
    required this.id,
    required this.nome,
    required this.duracaoEstimadaMinutos,
    required this.frequenciaSemanal,
    required this.diasSemana,
    required this.statusAtivo,
    required this.streakAtual,
    required this.pilar,
    this.descricao,
    this.horarioPadrao,
    this.checklists = const <ChecklistEntity>[],
  });

  factory RotinaHabitoEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawDias =
        json['diasSemana'] as List<dynamic>? ?? <dynamic>[1, 2, 3, 4, 5, 6, 7];
    final List<int> diasSemana = rawDias
        .map((e) => e is int ? e : (int.tryParse(e.toString()) ?? 1))
        .toList();

    final List<dynamic> rawChecklists =
        json['checklists'] as List<dynamic>? ?? <dynamic>[];
    final List<ChecklistEntity> checklists = rawChecklists
        .map((c) => ChecklistEntity.fromJson(c as Map<String, dynamic>))
        .toList();

    return RotinaHabitoEntity(
      id: json['id'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String?,
      duracaoEstimadaMinutos: json['duracaoEstimadaMinutos'] as int? ?? 30,
      frequenciaSemanal:
          json['frequenciaSemanal'] as int? ?? diasSemana.length,
      diasSemana: diasSemana,
      horarioPadrao: json['horarioPadrao'] as String?,
      statusAtivo: json['statusAtivo'] as bool? ?? true,
      streakAtual: json['streakAtual'] as int? ?? 0,
      pilar: PilarResumoEntity.fromJson(
        json['pilar'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      checklists: checklists,
    );
  }

  final String id;
  final String nome;
  final String? descricao;
  final int duracaoEstimadaMinutos;
  final int frequenciaSemanal;
  final List<int> diasSemana; // 1=Seg..7=Dom
  final String? horarioPadrao; // 'HH:mm'
  final bool statusAtivo;
  final int streakAtual;
  final PilarResumoEntity pilar;
  final List<ChecklistEntity> checklists;

  TimelineItemEntity toTimelineItem() {
    return TimelineItemEntity(
      id: id,
      natureza: NaturezaItem.habito,
      tipoItem: 'HABITO',
      horario: horarioPadrao,
      nome: nome,
      descricao: descricao,
      duracaoEstimadaMinutos: duracaoEstimadaMinutos,
      prioridade: TaskPriority.prioridade,
      indicadorDependencia: 'MINHAS_ACOES',
      concluido: false,
      streakAtual: streakAtual,
      pilar: pilar,
      checklists: checklists,
    );
  }

  RotinaHabitoEntity copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? duracaoEstimadaMinutos,
    int? frequenciaSemanal,
    List<int>? diasSemana,
    String? horarioPadrao,
    bool? statusAtivo,
    int? streakAtual,
    PilarResumoEntity? pilar,
    List<ChecklistEntity>? checklists,
  }) {
    return RotinaHabitoEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      duracaoEstimadaMinutos:
          duracaoEstimadaMinutos ?? this.duracaoEstimadaMinutos,
      frequenciaSemanal: frequenciaSemanal ?? this.frequenciaSemanal,
      diasSemana: diasSemana ?? this.diasSemana,
      horarioPadrao: horarioPadrao ?? this.horarioPadrao,
      statusAtivo: statusAtivo ?? this.statusAtivo,
      streakAtual: streakAtual ?? this.streakAtual,
      pilar: pilar ?? this.pilar,
      checklists: checklists ?? this.checklists,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        nome,
        descricao,
        duracaoEstimadaMinutos,
        frequenciaSemanal,
        diasSemana,
        horarioPadrao,
        statusAtivo,
        streakAtual,
        pilar,
        checklists,
      ];
}
