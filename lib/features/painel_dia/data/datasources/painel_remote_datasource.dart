import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/checklist_entity.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_dia_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/painel_semana_bundle.dart';
import 'package:produtividade_tcc/features/painel_dia/domain/entities/projeto_entity.dart';

abstract interface class PainelRemoteDataSource {
  Future<PainelDiaBundle> getPainelDia(String data);
  Future<PainelSemanaBundle> getPainelSemana(String dataReferencia);
  Future<List<Map<String, dynamic>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  });

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateTask(
    String id,
    Map<String, dynamic> payload,
  );
  Future<void> deleteTask(String id);
  Future<void> toggleTaskStatus(String id, bool concluido);

  Future<List<ProjetoEntity>> getProjetos({String? status});
  Future<ProjetoEntity> createProjeto(Map<String, dynamic> payload);

  Future<List<ChecklistEntity>> getChecklists({bool? ehModelo});
  Future<ChecklistEntity> createChecklist(Map<String, dynamic> payload);
  Future<ChecklistEntity> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  });
  Future<void> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  });
  Future<ItemChecklistEntity> addChecklistItem({
    required String idChecklist,
    required String descricao,
  });
  Future<Map<String, dynamic>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  );
}

class DioPainelRemoteDataSource implements PainelRemoteDataSource {
  DioPainelRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<PainelDiaBundle> getPainelDia(String data) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/painel/dia',
      queryParameters: <String, dynamic>{'data': data},
    );
    return PainelDiaBundle.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PainelSemanaBundle> getPainelSemana(String dataReferencia) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/painel/semana',
      queryParameters: <String, dynamic>{'dataReferencia': dataReferencia},
    );
    return PainelSemanaBundle.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Map<String, dynamic>>> getDiasLivres({
    required String dataOrigem,
    int duracaoMinutos = 60,
  }) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/painel/dias-livres',
      queryParameters: <String, dynamic>{
        'dataOrigem': dataOrigem,
        'duracaoMinutos': duracaoMinutos,
      },
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic> && data['sugeridos'] is List) {
      return (data['sugeridos'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is List) {
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/tarefas',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateTask(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await dio.patch<dynamic>(
      '/tarefas/$id',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteTask(String id) async {
    await dio.delete<dynamic>('/tarefas/$id');
  }

  @override
  Future<void> toggleTaskStatus(String id, bool concluido) async {
    await dio.patch<dynamic>(
      '/tarefas/$id',
      data: <String, dynamic>{
        'status': concluido ? 'CONCLUIDA' : 'PENDENTE',
      },
    );
  }

  @override
  Future<List<ProjetoEntity>> getProjetos({String? status}) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/projetos',
      queryParameters: status != null
          ? <String, dynamic>{'status': status}
          : null,
    );
    final List<dynamic> list = response.data as List<dynamic>? ?? <dynamic>[];
    return list
        .map((p) => ProjetoEntity.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProjetoEntity> createProjeto(Map<String, dynamic> payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/projetos',
      data: payload,
    );
    return ProjetoEntity.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ChecklistEntity>> getChecklists({bool? ehModelo}) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/checklists',
      queryParameters: ehModelo != null
          ? <String, dynamic>{'ehModelo': ehModelo}
          : null,
    );
    final List<dynamic> list = response.data as List<dynamic>? ?? <dynamic>[];
    return list
        .map((c) => ChecklistEntity.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChecklistEntity> createChecklist(Map<String, dynamic> payload) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/checklists',
      data: payload,
    );
    return ChecklistEntity.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ChecklistEntity> cloneChecklist({
    required String idModelo,
    String? idTarefa,
    String? idHabito,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (idTarefa != null) body['idTarefa'] = idTarefa;
    if (idHabito != null) body['idHabito'] = idHabito;

    final Response<dynamic> response = await dio.post<dynamic>(
      '/checklists/$idModelo/clonar',
      data: body,
    );
    return ChecklistEntity.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> toggleChecklistItem({
    required String idChecklist,
    required String itemId,
    required bool concluido,
  }) async {
    await dio.patch<dynamic>(
      '/checklists/$idChecklist/itens/$itemId',
      data: <String, dynamic>{'concluido': concluido},
    );
  }

  @override
  Future<ItemChecklistEntity> addChecklistItem({
    required String idChecklist,
    required String descricao,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/checklists/$idChecklist/itens',
      data: <String, dynamic>{'descricao': descricao},
    );
    return ItemChecklistEntity.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> registrarSessaoPomodoro(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/pomodoro/sessoes',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }
}

final Provider<PainelRemoteDataSource> painelRemoteDataSourceProvider =
    Provider<PainelRemoteDataSource>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return DioPainelRemoteDataSource(dio: dio);
});
