import 'package:equatable/equatable.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/capacidade_dia_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/pilar_resumo_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/timeline_item_entity.dart';

class PainelDiaBundle extends Equatable {
  const PainelDiaBundle({
    required this.data,
    required this.pilaresAtivosMes,
    required this.capacidadeDia,
    required this.itensLinhaTempo,
    required this.itensEmEspera,
  });

  const PainelDiaBundle.vazio(String data)
      : this(
          data: data,
          pilaresAtivosMes: const <PilarResumoEntity>[],
          capacidadeDia: const CapacidadeDiaEntity.padrao(),
          itensLinhaTempo: const <TimelineItemEntity>[],
          itensEmEspera: const <TimelineItemEntity>[],
        );

  factory PainelDiaBundle.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPilares =
        json['pilaresAtivosMes'] as List<dynamic>? ?? <dynamic>[];
    final List<PilarResumoEntity> pilares = rawPilares
        .map((p) => PilarResumoEntity.fromJson(p as Map<String, dynamic>))
        .toList();

    final List<dynamic> rawLinha =
        json['itensLinhaTempo'] as List<dynamic>? ?? <dynamic>[];
    final List<TimelineItemEntity> linha = rawLinha
        .map((i) => TimelineItemEntity.fromJson(i as Map<String, dynamic>))
        .toList();

    final List<dynamic> rawEspera =
        json['itensEmEspera'] as List<dynamic>? ?? <dynamic>[];
    final List<TimelineItemEntity> espera = rawEspera
        .map((i) => TimelineItemEntity.fromJson(i as Map<String, dynamic>))
        .toList();

    return PainelDiaBundle(
      data: json['data'] as String,
      pilaresAtivosMes: pilares,
      capacidadeDia: CapacidadeDiaEntity.fromJson(
        json['capacidadeDia'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      itensLinhaTempo: linha,
      itensEmEspera: espera,
    );
  }

  PainelDiaBundle copyWith({
    String? data,
    List<PilarResumoEntity>? pilaresAtivosMes,
    CapacidadeDiaEntity? capacidadeDia,
    List<TimelineItemEntity>? itensLinhaTempo,
    List<TimelineItemEntity>? itensEmEspera,
  }) {
    return PainelDiaBundle(
      data: data ?? this.data,
      pilaresAtivosMes: pilaresAtivosMes ?? this.pilaresAtivosMes,
      capacidadeDia: capacidadeDia ?? this.capacidadeDia,
      itensLinhaTempo: itensLinhaTempo ?? this.itensLinhaTempo,
      itensEmEspera: itensEmEspera ?? this.itensEmEspera,
    );
  }

  final String data;
  final List<PilarResumoEntity> pilaresAtivosMes;
  final CapacidadeDiaEntity capacidadeDia;
  final List<TimelineItemEntity> itensLinhaTempo;
  final List<TimelineItemEntity> itensEmEspera;

  @override
  List<Object?> get props => <Object?>[
        data,
        pilaresAtivosMes,
        capacidadeDia,
        itensLinhaTempo,
        itensEmEspera,
      ];
}
