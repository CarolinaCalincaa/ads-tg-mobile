import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TipoLembrete {
  agua,
  alongamento,
  sono,
  fechamentoSemanal;

  String toApiCode() {
    return switch (this) {
      TipoLembrete.agua => 'AGUA',
      TipoLembrete.alongamento => 'ALONGAMENTO',
      TipoLembrete.sono => 'SONO',
      TipoLembrete.fechamentoSemanal => 'FECHAMENTO_SEMANAL',
    };
  }

  static TipoLembrete fromApiCode(String? code) {
    return switch (code?.toUpperCase()) {
      'AGUA' => TipoLembrete.agua,
      'ALONGAMENTO' => TipoLembrete.alongamento,
      'SONO' => TipoLembrete.sono,
      'FECHAMENTO_SEMANAL' => TipoLembrete.fechamentoSemanal,
      _ => TipoLembrete.agua,
    };
  }
}

/// Entidade de Configuração de Lembrete Cognitivo Saudável (`RF21`).
class LembreteConfigEntity extends Equatable {
  const LembreteConfigEntity({
    required this.tipo,
    this.id,
    this.ativo = true,
    this.intervaloMinutos,
    this.horarioFixo,
    this.janelaInicio = '08:00',
    this.janelaFim = '21:00',
  });

  factory LembreteConfigEntity.fromJson(Map<String, dynamic> json) {
    final String tipoStr = json['tipo'] as String? ?? 'AGUA';
    return LembreteConfigEntity(
      id: json['id'] as String? ?? json['idLembrete'] as String?,
      tipo: TipoLembrete.fromApiCode(tipoStr),
      ativo: json['ativo'] as bool? ?? true,
      intervaloMinutos: json['intervaloMinutos'] as int?,
      horarioFixo: json['horarioFixo'] as String?,
      janelaInicio: json['janelaInicio'] as String? ?? '08:00',
      janelaFim: json['janelaFim'] as String? ?? '21:00',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'tipo': tipo.toApiCode(),
      'ativo': ativo,
      if (intervaloMinutos != null) 'intervaloMinutos': intervaloMinutos,
      if (horarioFixo != null) 'horarioFixo': horarioFixo,
      'janelaInicio': janelaInicio,
      'janelaFim': janelaFim,
    };
  }

  final String? id;
  final TipoLembrete tipo;
  final bool ativo;
  final int? intervaloMinutos;
  final String? horarioFixo;
  final String janelaInicio;
  final String janelaFim;

  String get titulo {
    return switch (tipo) {
      TipoLembrete.agua => '💧 Hidratação (Água)',
      TipoLembrete.alongamento => '🧘 Pausa & Alongamento',
      TipoLembrete.sono => '🌙 Ritual de Sono',
      TipoLembrete.fechamentoSemanal => '📝 Fechamento Semanal',
    };
  }

  String get descricao {
    return switch (tipo) {
      TipoLembrete.agua =>
        'Lembrete periódico para ingestão de água dentro da janela de vigília útil.',
      TipoLembrete.alongamento =>
        'Pausa ativa para descanso visual, correção postural e alongamento.',
      TipoLembrete.sono =>
        'Alerta fixo noturno para desligar telas e iniciar a desaceleração pré-sono.',
      TipoLembrete.fechamentoSemanal =>
        'Lembrete nas noites de domingo para consolidação do ciclo e reflexão.',
    };
  }

  IconData get icone {
    return switch (tipo) {
      TipoLembrete.agua => Icons.water_drop_outlined,
      TipoLembrete.alongamento => Icons.self_improvement_rounded,
      TipoLembrete.sono => Icons.nightlight_outlined,
      TipoLembrete.fechamentoSemanal => Icons.rate_review_outlined,
    };
  }

  LembreteConfigEntity copyWith({
    String? id,
    TipoLembrete? tipo,
    bool? ativo,
    int? intervaloMinutos,
    String? horarioFixo,
    String? janelaInicio,
    String? janelaFim,
    bool clearHorarioFixo = false,
    bool clearIntervalo = false,
  }) {
    return LembreteConfigEntity(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      intervaloMinutos:
          clearIntervalo ? null : (intervaloMinutos ?? this.intervaloMinutos),
      horarioFixo:
          clearHorarioFixo ? null : (horarioFixo ?? this.horarioFixo),
      janelaInicio: janelaInicio ?? this.janelaInicio,
      janelaFim: janelaFim ?? this.janelaFim,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        tipo,
        ativo,
        intervaloMinutos,
        horarioFixo,
        janelaInicio,
        janelaFim,
      ];

  /// Configurações canônicas padrão para novos usuários do TCC.
  static const List<LembreteConfigEntity> padroes = <LembreteConfigEntity>[
    LembreteConfigEntity(
      tipo: TipoLembrete.agua,
      ativo: true,
      intervaloMinutos: 90,
      janelaInicio: '08:00',
      janelaFim: '21:00',
    ),
    LembreteConfigEntity(
      tipo: TipoLembrete.alongamento,
      ativo: true,
      intervaloMinutos: 120,
      janelaInicio: '09:00',
      janelaFim: '18:00',
    ),
    LembreteConfigEntity(
      tipo: TipoLembrete.sono,
      ativo: true,
      horarioFixo: '22:00',
      janelaInicio: '22:00',
      janelaFim: '23:00',
    ),
    LembreteConfigEntity(
      tipo: TipoLembrete.fechamentoSemanal,
      ativo: true,
      horarioFixo: '20:00',
      janelaInicio: '20:00',
      janelaFim: '22:00',
    ),
  ];
}
