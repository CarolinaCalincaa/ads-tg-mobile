import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/core/widgets/priority_badge.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';

enum NaturezaItem {
  tarefa,
  habito,
}

class TimelineItemEntity extends Equatable {
  const TimelineItemEntity({
    required this.id,
    required this.natureza,
    required this.tipoItem,
    required this.nome,
    required this.duracaoEstimadaMinutos,
    required this.prioridade,
    required this.indicadorDependencia,
    required this.concluido,
    required this.pilar,
    this.horario,
    this.descricao,
    this.concluidaEm,
    this.streakAtual,
    this.diasSemana,
    this.pomodorosConcluidos = 0,
    this.projeto,
    this.checklists = const <ChecklistEntity>[],
  });

  factory TimelineItemEntity.fromJson(Map<String, dynamic> json) {
    final String natStr = (json['natureza'] as String?)?.toUpperCase() ?? 'TAREFA';
    final NaturezaItem natureza =
        natStr == 'HABITO' ? NaturezaItem.habito : NaturezaItem.tarefa;

    final String prioridadeStr = (json['prioridade'] as String?) ?? 'PRIORIDADE';
    final TaskPriority prioridade = TaskPriority.fromApiCode(prioridadeStr);

    final List<dynamic> rawChecklists =
        json['checklists'] as List<dynamic>? ?? <dynamic>[];
    final List<ChecklistEntity> checklists = rawChecklists
        .map((c) => ChecklistEntity.fromJson(c as Map<String, dynamic>))
        .toList();

    final List<dynamic>? rawDias = json['diasSemana'] as List<dynamic>?;
    final List<int>? diasSemana = rawDias
        ?.map((e) => e is int ? e : (int.tryParse(e.toString()) ?? 1))
        .toList();

    return TimelineItemEntity(
      id: json['id'] as String,
      natureza: natureza,
      tipoItem: json['tipoItem'] as String? ?? 'TAREFA',
      horario: json['horario'] as String?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      duracaoEstimadaMinutos: json['duracaoEstimadaMinutos'] as int? ?? 15,
      prioridade: prioridade,
      indicadorDependencia:
          json['indicadorDependencia'] as String? ?? 'MINHAS_ACOES',
      concluido: json['concluido'] as bool? ?? false,
      concluidaEm: json['concluidaEm'] as String?,
      streakAtual: json['streakAtual'] as int?,
      diasSemana: diasSemana,
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
  final NaturezaItem natureza;
  final String tipoItem;
  final String? horario;
  final String nome;
  final String? descricao;
  final int duracaoEstimadaMinutos;
  final TaskPriority prioridade;
  final String indicadorDependencia;
  final bool concluido;
  final String? concluidaEm;
  final int? streakAtual;
  final List<int>? diasSemana;
  final int pomodorosConcluidos;
  final PilarResumoEntity pilar;
  final ProjetoEntity? projeto;
  final List<ChecklistEntity> checklists;

  bool get ehHabito => natureza == NaturezaItem.habito;
  bool get ehCompromisso => tipoItem == 'COMPROMISSO';

  int get totalChecklistItens =>
      checklists.fold(0, (sum, c) => sum + c.totalItens);
  int get concluidosChecklistItens =>
      checklists.fold(0, (sum, c) => sum + c.itensConcluidos);

  TimelineItemEntity copyWith({
    String? id,
    NaturezaItem? natureza,
    String? tipoItem,
    String? horario,
    String? nome,
    String? descricao,
    int? duracaoEstimadaMinutos,
    TaskPriority? prioridade,
    String? indicadorDependencia,
    bool? concluido,
    String? concluidaEm,
    int? streakAtual,
    List<int>? diasSemana,
    int? pomodorosConcluidos,
    PilarResumoEntity? pilar,
    ProjetoEntity? projeto,
    List<ChecklistEntity>? checklists,
  }) {
    return TimelineItemEntity(
      id: id ?? this.id,
      natureza: natureza ?? this.natureza,
      tipoItem: tipoItem ?? this.tipoItem,
      horario: horario ?? this.horario,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      duracaoEstimadaMinutos:
          duracaoEstimadaMinutos ?? this.duracaoEstimadaMinutos,
      prioridade: prioridade ?? this.prioridade,
      indicadorDependencia: indicadorDependencia ?? this.indicadorDependencia,
      concluido: concluido ?? this.concluido,
      concluidaEm: concluidaEm ?? this.concluidaEm,
      streakAtual: streakAtual ?? this.streakAtual,
      diasSemana: diasSemana ?? this.diasSemana,
      pomodorosConcluidos: pomodorosConcluidos ?? this.pomodorosConcluidos,
      pilar: pilar ?? this.pilar,
      projeto: projeto ?? this.projeto,
      checklists: checklists ?? this.checklists,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        natureza,
        tipoItem,
        horario,
        nome,
        descricao,
        duracaoEstimadaMinutos,
        prioridade,
        indicadorDependencia,
        concluido,
        concluidaEm,
        streakAtual,
        diasSemana,
        pomodorosConcluidos,
        pilar,
        projeto,
        checklists,
      ];
}
