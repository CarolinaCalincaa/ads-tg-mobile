import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';

class ProjetoEntity extends Equatable {
  const ProjetoEntity({
    required this.id,
    required this.nome,
    this.idPilar,
    this.descricao,
    this.dataInicio,
    this.dataFimPrevista,
    this.horasEstimadasTotais,
    this.status = 'EM_ANDAMENTO',
    this.pilar,
    this.totalTarefas = 0,
  });

  factory ProjetoEntity.fromJson(Map<String, dynamic> json) {
    return ProjetoEntity(
      id: json['id'] as String,
      nome: json['nome'] as String,
      idPilar: json['idPilar'] as int?,
      descricao: json['descricao'] as String?,
      dataInicio: json['dataInicio'] as String?,
      dataFimPrevista: json['dataFimPrevista'] as String?,
      horasEstimadasTotais: (json['horasEstimadasTotais'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'EM_ANDAMENTO',
      pilar: json['pilar'] != null
          ? PilarResumoEntity.fromJson(json['pilar'] as Map<String, dynamic>)
          : null,
      totalTarefas: json['totalTarefas'] as int? ?? 0,
    );
  }

  final String id;
  final String nome;
  final int? idPilar;
  final String? descricao;
  final String? dataInicio;
  final String? dataFimPrevista;
  final double? horasEstimadasTotais;
  final String status;
  final PilarResumoEntity? pilar;
  final int totalTarefas;

  @override
  List<Object?> get props => <Object?>[
        id,
        nome,
        idPilar,
        descricao,
        dataInicio,
        dataFimPrevista,
        horasEstimadasTotais,
        status,
        pilar,
        totalTarefas,
      ];
}
