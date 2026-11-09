import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/network/dio_client.dart';
import 'package:produtividade_tcc/features/pilares/domain/entities/pilar_entity.dart';

abstract interface class PilaresRemoteDataSource {
  Future<List<PilarEntity>> getPilares();
  Future<List<int>> getPilaresAtivos(String mesAno);
  Future<List<int>> setPilaresAtivos(String mesAno, List<int> idsPilares);
}

class DioPilaresRemoteDataSource implements PilaresRemoteDataSource {
  DioPilaresRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<List<PilarEntity>> getPilares() async {
    final Response<dynamic> response = await dio.get<dynamic>('/pilares');
    final List<dynamic> list = response.data as List<dynamic>? ?? <dynamic>[];
    return list
        .map((p) => PilarEntity.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<int>> getPilaresAtivos(String mesAno) async {
    final Response<dynamic> response = await dio.get<dynamic>(
      '/pilares/ativos',
      queryParameters: <String, dynamic>{'mesAno': mesAno},
    );
    final dynamic data = response.data;
    if (data is List) {
      return data.map((item) {
        if (item is int) return item;
        if (item is Map<String, dynamic>) {
          return item['idPilar'] as int? ?? item['id'] as int? ?? 0;
        }
        return 0;
      }).where((id) => id > 0).toList();
    }
    return <int>[];
  }

  @override
  Future<List<int>> setPilaresAtivos(String mesAno, List<int> idsPilares) async {
    final Response<dynamic> response = await dio.put<dynamic>(
      '/pilares/ativos/$mesAno',
      data: <String, dynamic>{'idsPilares': idsPilares},
    );
    final dynamic data = response.data;
    if (data is List) {
      return data.map((item) {
        if (item is int) return item;
        if (item is Map<String, dynamic>) {
          return item['idPilar'] as int? ?? item['id'] as int? ?? 0;
        }
        return 0;
      }).where((id) => id > 0).toList();
    }
    return idsPilares;
  }
}

final Provider<PilaresRemoteDataSource> pilaresRemoteDataSourceProvider =
    Provider<PilaresRemoteDataSource>((Ref ref) {
  final Dio dio = ref.watch(dioProvider);
  return DioPilaresRemoteDataSource(dio: dio);
});
