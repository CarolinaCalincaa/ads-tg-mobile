import 'package:equatable/equatable.dart';

class PilarResumoEntity extends Equatable {
  const PilarResumoEntity({
    required this.idPilar,
    required this.codigo,
    required this.nome,
    required this.corHex,
    required this.corFundoHex,
    required this.icone,
  });

  factory PilarResumoEntity.fromJson(Map<String, dynamic> json) {
    return PilarResumoEntity(
      idPilar: json['idPilar'] as int? ?? json['id'] as int? ?? 1,
      codigo: json['codigo'] as String? ?? 'GERAL',
      nome: json['nome'] as String? ?? 'Geral',
      corHex: json['corHex'] as String? ?? '#0EA5E9',
      corFundoHex: json['corFundoHex'] as String? ?? '#F0F9FF',
      icone: json['icone'] as String? ?? 'activity',
    );
  }

  final int idPilar;
  final String codigo;
  final String nome;
  final String corHex;
  final String corFundoHex;
  final String icone;

  @override
  List<Object?> get props => <Object?>[
        idPilar,
        codigo,
        nome,
        corHex,
        corFundoHex,
        icone,
      ];
}
