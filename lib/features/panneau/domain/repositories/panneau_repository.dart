import '../models/panneau.dart';

abstract class PanneauRepository {
  Future<List<Panneau>> getPanneaux(String bbox);
  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  });
  Future<Panneau> createPanneau(PanneauCreationPayload payload);
  Future<Panneau> votePanneau({
    required String panneauId,
    required bool isUpvote,
    required String userId,
  });
  Future<List<Panneau>> getUserPanneaux(String userId);
}
