import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/fechamento/domain/entities/fechamento_entity.dart';

abstract interface class FechamentoRemoteDataSource {
  Future<FechamentoPrevia> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  });

  Future<FechamentoEntity> salvarFechamento(Map<String, dynamic> payload);

  Future<List<FechamentoEntity>> getHistorico({String? tipoCiclo});

  Future<FechamentoEntity> getFechamentoById(String id);
}

class FechamentoRemoteDataSourceImpl implements FechamentoRemoteDataSource {
  FechamentoRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<FechamentoPrevia> getPrevia({
    required String tipoCiclo,
    required String dataRef,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/fechamentos/previa',
      queryParameters: <String, dynamic>{
        'tipoCiclo': tipoCiclo,
        'dataRef': dataRef,
      },
    );

    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return FechamentoPrevia.fromJson(data);
    }
    throw const FormatException('Resposta inválida do endpoint de prévia');
  }

  @override
  Future<FechamentoEntity> salvarFechamento(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/fechamentos',
      data: payload,
    );

    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return FechamentoEntity.fromJson(data);
    }
    throw const FormatException('Resposta inválida ao salvar fechamento');
  }

  @override
  Future<List<FechamentoEntity>> getHistorico({String? tipoCiclo}) async {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (tipoCiclo != null && tipoCiclo.isNotEmpty && tipoCiclo != 'TODOS') {
      query['tipoCiclo'] = tipoCiclo;
    }

    final Response<dynamic> response = await dio.get<dynamic>(
      '/fechamentos',
      queryParameters: query,
    );

    final dynamic data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(FechamentoEntity.fromJson)
          .toList();
    }
    return <FechamentoEntity>[];
  }

  @override
  Future<FechamentoEntity> getFechamentoById(String id) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/fechamentos/$id',
    );

    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return FechamentoEntity.fromJson(data);
    }
    throw const FormatException('Fechamento não encontrado');
  }
}

final Provider<FechamentoRemoteDataSource>
    fechamentoRemoteDataSourceProvider = Provider<FechamentoRemoteDataSource>(
  (Ref ref) => FechamentoRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);
