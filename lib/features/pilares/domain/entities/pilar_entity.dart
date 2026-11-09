import 'package:equatable/equatable.dart';

/// Representação de um Pilar de Vida Mestre (`Tech Doc 02 — Seção 2`).
class PilarEntity extends Equatable {
  const PilarEntity({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.corHex,
    required this.corFundoHex,
    required this.icone,
    required this.descricao,
  });

  factory PilarEntity.fromJson(Map<String, dynamic> json) {
    return PilarEntity(
      id: json['id'] as int? ?? json['idPilar'] as int? ?? 1,
      codigo: json['codigo'] as String? ?? 'GERAL',
      nome: json['nome'] as String? ?? 'Geral',
      corHex: json['corHex'] as String? ?? '#0EA5E9',
      corFundoHex: json['corFundoHex'] as String? ?? '#F0F9FF',
      icone: json['icone'] as String? ?? 'activity',
      descricao: json['descricao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'corHex': corHex,
      'corFundoHex': corFundoHex,
      'icone': icone,
      'descricao': descricao,
    };
  }

  final int id;
  final String codigo;
  final String nome;
  final String corHex;
  final String corFundoHex;
  final String icone;
  final String descricao;

  @override
  List<Object?> get props => <Object?>[
        id,
        codigo,
        nome,
        corHex,
        corFundoHex,
        icone,
        descricao,
      ];

  /// Os 7 Pilares Mestres Canônicos definidos pelo TCC.
  static const List<PilarEntity> pilaresMestresCanonicos = <PilarEntity>[
    PilarEntity(
      id: 1,
      codigo: 'SAUDE',
      nome: 'Saúde',
      corHex: '#EF4444',
      corFundoHex: '#FEF2F2',
      icone: 'heart_pulse',
      descricao:
          'Práticas saudáveis diárias, nutrição, exames de rotina e consultas preventivas.',
    ),
    PilarEntity(
      id: 2,
      codigo: 'MOVIMENTO',
      nome: 'Movimento',
      corHex: '#F97316',
      corFundoHex: '#FFF7ED',
      icone: 'activity',
      descricao:
          'Atividade física, meta semanal de treinos e consistência corporal.',
    ),
    PilarEntity(
      id: 3,
      codigo: 'SONO',
      nome: 'Sono',
      corHex: '#6366F1',
      corFundoHex: '#EEF2FF',
      icone: 'moon',
      descricao:
          'Quantidade/qualidade de horas dormidas e higiene do sono sem telas.',
    ),
    PilarEntity(
      id: 4,
      codigo: 'MENTE',
      nome: 'Mente',
      corHex: '#8B5CF6',
      corFundoHex: '#F5F3FF',
      icone: 'brain',
      descricao:
          'Meditação, diário de reflexão, pausas de descompressão, alongamento e hidratação.',
    ),
    PilarEntity(
      id: 5,
      codigo: 'ESTUDOS',
      nome: 'Estudos',
      corHex: '#10B981',
      corFundoHex: '#ECFDF5',
      icone: 'book_open',
      descricao:
          'Leitura, cursos, projetos acadêmicos e aquisição de novos conhecimentos.',
    ),
    PilarEntity(
      id: 6,
      codigo: 'FINANCAS',
      nome: 'Finanças',
      corHex: '#CA8A04',
      corFundoHex: '#FEFCE8',
      icone: 'wallet',
      descricao:
          'Controle manual de despesas recorrentes, orçamento e metas de investimento.',
    ),
    PilarEntity(
      id: 7,
      codigo: 'CARREIRA',
      nome: 'Carreira',
      corHex: '#0EA5E9',
      corFundoHex: '#F0F9FF',
      icone: 'briefcase',
      descricao:
          'Metas profissionais, projetos estratégicos, reuniões e entregas de alto impacto.',
    ),
  ];
}
