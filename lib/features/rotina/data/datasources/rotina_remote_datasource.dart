import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/rotina/domain/entities/rotina_entities.dart';

abstract interface class RotinaRemoteDataSource {
  Future<List<RotinaTarefaEntity>> getAllTarefas();
  Future<List<RotinaHabitoEntity>> getAllHabitos();
  Future<void> toggleTarefaStatus(String id, bool concluido);
  Future<void> deleteTarefa(String id);
  Future<void> toggleHabitoAtivo(String id, bool statusAtivo);
  Future<void> deleteHabito(String id);
}

class DioRotinaRemoteDataSource implements RotinaRemoteDataSource {
  DioRotinaRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<RotinaTarefaEntity>> getAllTarefas() async {
    final Response<dynamic> response = await dio.get<dynamic>('/tarefas');
    final dynamic data = response.data;
    if (data is List) {
      return data
          .map((e) => RotinaTarefaEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <RotinaTarefaEntity>[];
  }

  @override
  Future<List<RotinaHabitoEntity>> getAllHabitos() async {
    final Response<dynamic> response = await dio.get<dynamic>('/habitos');
    final dynamic data = response.data;
    if (data is List) {
      return data
          .map((e) => RotinaHabitoEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <RotinaHabitoEntity>[];
  }

  @override
  Future<void> toggleTarefaStatus(String id, bool concluido) async {
    await dio.patch<dynamic>(
      '/tarefas/$id',
      data: <String, dynamic>{
        'status': concluido ? 'CONCLUIDA' : 'PENDENTE',
      },
    );
  }

  @override
  Future<void> deleteTarefa(String id) async {
    await dio.delete<dynamic>('/tarefas/$id');
  }

  @override
  Future<void> toggleHabitoAtivo(String id, bool statusAtivo) async {
    await dio.patch<dynamic>(
      '/habitos/$id',
      data: <String, dynamic>{
        'statusAtivo': statusAtivo,
      },
    );
  }

  @override
  Future<void> deleteHabito(String id) async {
    await dio.delete<dynamic>('/habitos/$id');
  }
}

final Provider<RotinaRemoteDataSource> rotinaRemoteDataSourceProvider =
    Provider<RotinaRemoteDataSource>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return DioRotinaRemoteDataSource(dio: dio);
});
