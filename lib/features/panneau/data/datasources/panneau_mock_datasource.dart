import '../../domain/models/panneau.dart';

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
    ),
  ];

  Future<List<Panneau>> getPanneaux(String bbox) async {
    return List.from(_panneaux);
  }

  Future<DuplicateCheckResult> checkDuplicates({
    required double lat,
    required double lng,
    required PanneauCategory category,
    required String title,
  }) async {
    final duplicates = _panneaux.where((p) {
      final sameCategory = p.category == category;
      final similarTitle = p.title.toLowerCase().contains(title.toLowerCase()) ||
          title.toLowerCase().contains(p.title.toLowerCase());
      final distance = (p.lat - lat).abs() + (p.lng - lng).abs();
      return sameCategory && (similarTitle || distance < 0.01);
    }).toList();

    return DuplicateCheckResult(
      hasDuplicates: duplicates.isNotEmpty,
      duplicates: duplicates,
    );
  }

  Future<Panneau> createPanneau(PanneauCreationPayload payload) async {
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
    );

    _panneaux.add(newPanneau);
    return newPanneau;
  }
}
