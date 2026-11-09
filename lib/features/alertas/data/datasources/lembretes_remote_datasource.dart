import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/alertas/domain/entities/lembrete_config_entity.dart';

abstract interface class LembretesRemoteDataSource {
  Future<List<LembreteConfigEntity>> getLembretes();
  Future<List<LembreteConfigEntity>> saveLembretes(
    List<LembreteConfigEntity> configs,
  );
}

class DioLembretesRemoteDataSource implements LembretesRemoteDataSource {
  DioLembretesRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<LembreteConfigEntity>> getLembretes() async {
    final Response<dynamic> response = await dio.get<dynamic>('/lembretes');
    final dynamic data = response.data;
    if (data is List) {
      return data
          .map((item) =>
              LembreteConfigEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return <LembreteConfigEntity>[];
  }

  @override
  Future<List<LembreteConfigEntity>> saveLembretes(
    List<LembreteConfigEntity> configs,
  ) async {
    final List<Map<String, dynamic>> payload =
        configs.map((c) => c.toJson()).toList();
    final Response<dynamic> response = await dio.put<dynamic>(
      '/lembretes',
      data: <String, dynamic>{'lembretes': payload},
    );
    final dynamic data = response.data;
    if (data is List) {
      return data
          .map((item) =>
              LembreteConfigEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return configs;
  }
}

final Provider<LembretesRemoteDataSource> lembretesRemoteDataSourceProvider =
    Provider<LembretesRemoteDataSource>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return DioLembretesRemoteDataSource(dio: dio);
});
