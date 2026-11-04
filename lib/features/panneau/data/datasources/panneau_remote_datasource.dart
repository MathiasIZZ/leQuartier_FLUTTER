import 'package:dio/dio.dart';
import '../../domain/models/panneau.dart';

class PanneauRemoteDatasource {
  final Dio _dio;

  PanneauRemoteDatasource(this._dio);

  Future<List<Panneau>> getPanneaux(String bbox) async {
    final response = await _dio.get('/panneaux', queryParameters: {'bbox': bbox});
    final list = response.data as List<dynamic>;
    return list.map((json) => Panneau.fromJson(json)).toList();
  }

  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  }) async {
    final response = await _dio.post('/panneaux/check-duplicates', data: {
      'lat': lat,
      'lng': lng,
      'category': category.jsonValue,
      'title': title,
    });
    
    final hasDuplicates = response.data['hasDuplicates'] as bool? ?? false;
    final duplicatesList = response.data['duplicates'] as List<dynamic>? ?? [];
    final duplicates = duplicatesList.map((json) => Panneau.fromJson(json)).toList();

    return DuplicateCheckResult(
      hasDuplicates: hasDuplicates,
      duplicates: duplicates,
    );
  }

  Future<Panneau> createPanneau(PanneauCreationPayload payload, {String? userId}) async {
    final response = await _dio.post('/panneaux', data: {
      ...payload.toJson(),
      'createdByUserId': userId,
    });
    return Panneau.fromJson(response.data);
  }

  Future<Panneau> votePanneau({
    required String panneauId,
    required bool isUpvote,
    required String userId,
  }) async {
    final response = await _dio.post('/panneaux/$panneauId/vote', data: {
      'isUpvote': isUpvote,
      'userId': userId,
    });
    return Panneau.fromJson(response.data);
  }

  Future<List<Panneau>> getUserPanneaux(String userId) async {
    final response = await _dio.get('/panneaux/user/$userId');
    final list = response.data as List<dynamic>;
    return list.map((json) => Panneau.fromJson(json)).toList();
  }
}
