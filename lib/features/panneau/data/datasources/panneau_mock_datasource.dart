import '../../domain/models/panneau.dart';
import '../../../auth/data/datasources/auth_mock_datasource.dart';

class PanneauMockDatasource {
  final List<Panneau> _panneaux = [
    Panneau(
      id: '1',
      title: 'Brocante de quartier',
      description: 'Grand vide-grenier annuel rue Nationale',
      category: PanneauCategory.brocante,
      kind: PanneauKind.event,
      lat: 47.3900,
      lng: 0.6880,
      address: 'Rue Nationale, 37000 Tours',
      locationHint: 'Devant l’église Saint-Julien',
      startsAt: DateTime.now().add(const Duration(days: 1, hours: 8)),
      endsAt: DateTime.now().add(const Duration(days: 1, hours: 18)),
      creationMode: CreationMode.gps,
      verifiedOnSite: true,
      trustLevel: 3,
      score: 15,
      createdByUserId: 'mock_user_1',
    ),
    Panneau(
      id: '2',
      title: 'Concert de jazz acoustique',
      description: 'Musique live sur la place Plumereau',
      category: PanneauCategory.concert,
      kind: PanneauKind.event,
      lat: 47.3934,
      lng: 0.6848,
      address: 'Place Plumereau, 37000 Tours',
      locationHint: 'Sous les terrasses',
      startsAt: DateTime.now().add(const Duration(hours: 3)),
      endsAt: DateTime.now().add(const Duration(hours: 6)),
      creationMode: CreationMode.address,
      verifiedOnSite: false,
      trustLevel: 2,
      score: 5,
      createdByUserId: 'mock_user_2',
    ),
  ];

  Panneau _enrichPanneau(Panneau p) {
    if (p.createdByUserId == null) return p;
    final user = AuthMockDatasource.getUserById(p.createdByUserId!);
    if (user == null) return p;
    return p.copyWith(
      creatorPseudo: user.pseudo.isNotEmpty ? user.pseudo : 'Citoyen',
      creatorAura: user.auraScore,
    );
  }

  Future<List<Panneau>> getPanneaux(String bbox) async {
    return _panneaux
        .where((p) => p.status != PanneauStatus.supprime)
        .map((p) => _enrichPanneau(p))
        .toList();
  }

  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  }) async {
    final duplicates = _panneaux.where((p) {
      if (p.status == PanneauStatus.supprime) return false;
      final sameCategory = p.category == category;
      final similarTitle = p.title.toLowerCase().contains(title.toLowerCase()) ||
          title.toLowerCase().contains(p.title.toLowerCase());
      final distance = (p.lat - lat).abs() + (p.lng - lng).abs();
      return sameCategory && (similarTitle || distance < 0.01);
    }).map((p) => _enrichPanneau(p)).toList();

    return DuplicateCheckResult(
      hasDuplicates: duplicates.isNotEmpty,
      duplicates: duplicates,
    );
  }

  Future<Panneau> createPanneau(PanneauCreationPayload payload, {String? userId}) async {
    final newPanneau = Panneau(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: payload.title,
      description: payload.description,
      category: payload.category,
      kind: payload.kind,
      lat: payload.lat,
      lng: payload.lng,
      address: payload.address,
      locationHint: payload.locationHint,
      startsAt: payload.startsAt,
      endsAt: payload.endsAt,
      creationMode: payload.creationMode,
      deviceLocation: payload.deviceLocation,
      verifiedOnSite: payload.deviceLocation != null && payload.deviceLocation!.accuracy <= 30,
      trustLevel: 1,
      score: 0,
      createdByUserId: userId ?? 'current_user',
    );

    _panneaux.add(newPanneau);
    return _enrichPanneau(newPanneau);
  }

  Future<Panneau> votePanneau({
    required String panneauId,
    required bool isUpvote,
    required String userId,
  }) async {
    final index = _panneaux.indexWhere((p) => p.id == panneauId);
    if (index == -1) {
      throw Exception('Panneau introuvable');
    }

    final p = _panneaux[index];
    final upvoters = List<String>.from(p.upvoters);
    final downvoters = List<String>.from(p.downvoters);

    bool alreadyUp = upvoters.contains(userId);
    bool alreadyDown = downvoters.contains(userId);

    if (isUpvote) {
      if (alreadyUp) {
        upvoters.remove(userId);
      } else {
        if (alreadyDown) downvoters.remove(userId);
        upvoters.add(userId);
      }
    } else {
      if (alreadyDown) {
        downvoters.remove(userId);
      } else {
        if (alreadyUp) upvoters.remove(userId);
        downvoters.add(userId);
      }
    }

    int newScore = upvoters.length - downvoters.length;
    PanneauStatus newStatus = p.status;
    bool newVerified = p.verifiedOnSite;

    if (newScore <= -20 && p.status != PanneauStatus.supprime) {
      newStatus = PanneauStatus.supprime;
      if (p.createdByUserId != null) {
        AuthMockDatasource.adjustAura(p.createdByUserId!, -20);
      }
    } else if (newScore >= 20 && !p.verifiedOnSite) {
      newVerified = true;
      if (p.createdByUserId != null) {
        AuthMockDatasource.adjustAura(p.createdByUserId!, 15);
      }
    }

    final updated = p.copyWith(
      score: newScore,
      upvoters: upvoters,
      downvoters: downvoters,
      status: newStatus,
      verifiedOnSite: newVerified,
    );

    _panneaux[index] = updated;
    return _enrichPanneau(updated);
  }

  Future<List<Panneau>> getUserPanneaux(String userId) async {
    return _panneaux
        .where((p) => p.createdByUserId == userId)
        .map((p) => _enrichPanneau(p))
        .toList();
  }
}
