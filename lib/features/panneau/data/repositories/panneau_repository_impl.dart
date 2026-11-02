import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../../domain/repositories/panneau_repository.dart';
import '../datasources/panneau_mock_datasource.dart';

class PanneauRepositoryImpl implements PanneauRepository {
  final PanneauMockDatasource _mockDatasource;

  PanneauRepositoryImpl(this._mockDatasource);

  @override
  Future<List<Panneau>> getPanneaux(String bbox) {
    return _mockDatasource.getPanneaux(bbox);
  }

  @override
  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  }) {
    return _mockDatasource.checkDuplicates(
      lat: lat,
      lng: lng,
      category: category,
      title: title,
    );
  }

  @override
  Future<Panneau> createPanneau(PanneauCreationPayload payload) {
    return _mockDatasource.createPanneau(payload);
  }
}

final panneauMockDatasourceProvider = Provider<PanneauMockDatasource>((ref) {
  return PanneauMockDatasource();
});

final panneauRepositoryProvider = Provider<PanneauRepository>((ref) {
  final mock = ref.watch(panneauMockDatasourceProvider);
  return PanneauRepositoryImpl(mock);
});
