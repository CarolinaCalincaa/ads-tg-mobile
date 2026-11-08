import 'package:equatable/equatable.dart';

class ItemChecklistEntity extends Equatable {
  const ItemChecklistEntity({
    required this.id,
    required this.idChecklist,
    required this.descricao,
    required this.concluido,
    this.ordem = 1,
  });

  factory ItemChecklistEntity.fromJson(Map<String, dynamic> json) {
    return ItemChecklistEntity(
      id: json['id'] as String,
      idChecklist: json['idChecklist'] as String? ?? '',
      descricao: json['descricao'] as String,
      concluido: json['concluido'] as bool? ?? false,
      ordem: json['ordem'] as int? ?? 1,
    );
  }

  ItemChecklistEntity copyWith({
    String? id,
    String? idChecklist,
    String? descricao,
    bool? concluido,
    int? ordem,
  }) {
    return ItemChecklistEntity(
      id: id ?? this.id,
      idChecklist: idChecklist ?? this.idChecklist,
      descricao: descricao ?? this.descricao,
      concluido: concluido ?? this.concluido,
      ordem: ordem ?? this.ordem,
    );
  }

  final String id;
  final String idChecklist;
  final String descricao;
  final bool concluido;
  final int ordem;

  @override
  List<Object?> get props => <Object?>[id, idChecklist, descricao, concluido, ordem];
}

class ChecklistEntity extends Equatable {
  const ChecklistEntity({
    required this.id,
    required this.titulo,
    this.idTarefa,
    this.idHabito,
    this.ehModelo = false,
    this.totalItens = 0,
    this.itensConcluidos = 0,
    this.itens = const <ItemChecklistEntity>[],
  });

  factory ChecklistEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItens = json['itens'] as List<dynamic>? ?? <dynamic>[];
    final List<ItemChecklistEntity> itens = rawItens
        .map((e) => ItemChecklistEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChecklistEntity(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      idTarefa: json['idTarefa'] as String?,
      idHabito: json['idHabito'] as String?,
      ehModelo: json['ehModelo'] as bool? ?? false,
      totalItens: json['totalItens'] as int? ?? itens.length,
      itensConcluidos: json['itensConcluidos'] as int? ??
          itens.filterConcluidosCount(),
      itens: itens,
    );
  }

  ChecklistEntity copyWith({
    String? id,
    String? titulo,
    String? idTarefa,
    String? idHabito,
    bool? ehModelo,
    int? totalItens,
    int? itensConcluidos,
    List<ItemChecklistEntity>? itens,
  }) {
    return ChecklistEntity(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      idTarefa: idTarefa ?? this.idTarefa,
      idHabito: idHabito ?? this.idHabito,
      ehModelo: ehModelo ?? this.ehModelo,
      totalItens: totalItens ?? this.totalItens,
      itensConcluidos: itensConcluidos ?? this.itensConcluidos,
      itens: itens ?? this.itens,
    );
  }

  final String id;
  final String titulo;
  final String? idTarefa;
  final String? idHabito;
  final bool ehModelo;
  final int totalItens;
  final int itensConcluidos;
  final List<ItemChecklistEntity> itens;

  String get progressoFormatado => '$itensConcluidos/$totalItens';

  @override
  List<Object?> get props => <Object?>[
        id,
        titulo,
        idTarefa,
        idHabito,
        ehModelo,
        totalItens,
        itensConcluidos,
        itens,
      ];
}

extension _ItemListExt on List<ItemChecklistEntity> {
  int filterConcluidosCount() {
    return where((i) => i.concluido).length;
  }
}
