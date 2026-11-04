import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/panneau.dart';
import '../../domain/repositories/panneau_repository.dart';
import '../datasources/panneau_mock_datasource.dart';
import '../datasources/panneau_remote_datasource.dart';
import 'package:le_quartier/core/network/dio_client.dart';

class PanneauRepositoryImpl implements PanneauRepository {
  final PanneauMockDatasource? _mockDatasource;
  final PanneauRemoteDatasource? _remoteDatasource;
  final bool _useMock;

  const PanneauRepositoryImpl({
    PanneauMockDatasource? mockDatasource,
    PanneauRemoteDatasource? remoteDatasource,
    bool useMock = true,
  })  : _mockDatasource = mockDatasource,
        _remoteDatasource = remoteDatasource,
        _useMock = useMock;

  @override
  Future<List<Panneau>> getPanneaux(String bbox) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.getPanneaux(bbox);
    }
    return _remoteDatasource!.getPanneaux(bbox);
  }

  @override
  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  }) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.checkDuplicates(
        lat: lat,
        lng: lng,
        category: category,
        title: title,
      );
    }
    return _remoteDatasource!.checkDuplicates(
      lat: lat,
      lng: lng,
      category: category,
      title: title,
    );
  }

  @override
  Future<Panneau> createPanneau(PanneauCreationPayload payload) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.createPanneau(payload);
    }
    return _remoteDatasource!.createPanneau(payload);
  }

  @override
  Future<Panneau> votePanneau({
    required String panneauId,
    required bool isUpvote,
    required String userId,
  }) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.votePanneau(
        panneauId: panneauId,
        isUpvote: isUpvote,
        userId: userId,
      );
    }
    return _remoteDatasource!.votePanneau(
      panneauId: panneauId,
      isUpvote: isUpvote,
      userId: userId,
    );
  }

  @override
  Future<List<Panneau>> getUserPanneaux(String userId) {
    if (_useMock && _mockDatasource != null) {
      return _mockDatasource.getUserPanneaux(userId);
    }
    return _remoteDatasource!.getUserPanneaux(userId);
  }
}

final panneauMockDatasourceProvider = Provider<PanneauMockDatasource>((ref) {
  return PanneauMockDatasource();
});

final panneauRemoteDatasourceProvider = Provider<PanneauRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return PanneauRemoteDatasource(dio);
});

const bool kUseMockData = true;

final panneauRepositoryProvider = Provider<PanneauRepository>((ref) {
  return PanneauRepositoryImpl(
    mockDatasource: ref.watch(panneauMockDatasourceProvider),
    remoteDatasource: ref.watch(panneauRemoteDatasourceProvider),
    useMock: kUseMockData,
  );
});
