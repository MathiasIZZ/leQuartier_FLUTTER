enum PanneauCategory {
  brocante,
  concert,
  marche,
  feteQuartier,
  sport,
  autre,
}

extension PanneauCategoryExtension on PanneauCategory {
  String get jsonValue {
    switch (this) {
      case PanneauCategory.brocante:
        return 'BROCANTE';
      case PanneauCategory.concert:
        return 'CONCERT';
      case PanneauCategory.marche:
        return 'MARCHE';
      case PanneauCategory.feteQuartier:
        return 'FETE_QUARTIER';
      case PanneauCategory.sport:
        return 'SPORT';
      case PanneauCategory.autre:
        return 'AUTRE';
    }
  }

  String get label {
    switch (this) {
      case PanneauCategory.brocante:
        return 'Brocante / Vide-grenier';
      case PanneauCategory.concert:
        return 'Concert / Animation';
      case PanneauCategory.marche:
        return 'Marché / Commerce';
      case PanneauCategory.feteQuartier:
        return 'Fête de quartier';
      case PanneauCategory.sport:
        return 'Sport / Loisirs';
      case PanneauCategory.autre:
        return 'Autre';
    }
  }

  static PanneauCategory fromJson(String value) {
    switch (value) {
      case 'BROCANTE':
        return PanneauCategory.brocante;
      case 'CONCERT':
        return PanneauCategory.concert;
      case 'MARCHE':
        return PanneauCategory.marche;
      case 'FETE_QUARTIER':
        return PanneauCategory.feteQuartier;
      case 'SPORT':
        return PanneauCategory.sport;
      default:
        return PanneauCategory.autre;
    }
  }
}

enum PanneauKind {
  event,
  dailySpecial,
  permanentNotice,
}

extension PanneauKindExtension on PanneauKind {
  String get jsonValue {
    switch (this) {
      case PanneauKind.event:
        return 'EVENT';
      case PanneauKind.dailySpecial:
        return 'DAILY_SPECIAL';
      case PanneauKind.permanentNotice:
        return 'PERMANENT_NOTICE';
    }
  }

  String get label {
    switch (this) {
      case PanneauKind.event:
        return 'Événement ponctuel';
      case PanneauKind.dailySpecial:
        return 'Offre / Info du jour';
      case PanneauKind.permanentNotice:
        return 'Avis / Signalement permanent';
    }
  }

  static PanneauKind fromJson(String value) {
    switch (value) {
      case 'DAILY_SPECIAL':
        return PanneauKind.dailySpecial;
      case 'PERMANENT_NOTICE':
        return PanneauKind.permanentNotice;
      default:
        return PanneauKind.event;
    }
  }
}

enum CreationMode {
  gps,
  address,
}

enum PanneauStatus {
  actif,
  expire,
  signale,
  supprime,
}

class DeviceLocation {
  final double lat;
  final double lng;
  final double accuracy;
  final bool isMocked;

  const DeviceLocation({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.isMocked,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'isMocked': isMocked,
      };

  factory DeviceLocation.fromJson(Map<String, dynamic> json) => DeviceLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toDouble(),
        isMocked: json['isMocked'] as bool? ?? false,
      );
}

class Panneau {
  final String id;
  final String title;
  final String description;
  final PanneauCategory category;
  final PanneauKind kind;
  final double lat;
  final double lng;
  final String address;
  final String locationHint;
  final DateTime startsAt;
  final DateTime endsAt;
  final PanneauStatus status;
  final CreationMode creationMode;
  final List<String> photos;
  final bool verifiedOnSite;
  final String? organizationId;
  final int trustLevel;
  final DeviceLocation? deviceLocation;

  const Panneau({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.kind,
    required this.lat,
    required this.lng,
    required this.address,
    required this.locationHint,
    required this.startsAt,
    required this.endsAt,
    this.status = PanneauStatus.actif,
    required this.creationMode,
    this.photos = const [],
    this.verifiedOnSite = false,
    this.organizationId,
    this.trustLevel = 1,
    this.deviceLocation,
  });

  Panneau copyWith({
    String? id,
    String? title,
    String? description,
    PanneauCategory? category,
    PanneauKind? kind,
    double? lat,
    double? lng,
    String? address,
    String? locationHint,
    DateTime? startsAt,
    DateTime? endsAt,
    PanneauStatus? status,
    CreationMode? creationMode,
    List<String>? photos,
    bool? verifiedOnSite,
    String? organizationId,
    int? trustLevel,
    DeviceLocation? deviceLocation,
  }) {
    return Panneau(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      kind: kind ?? this.kind,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      locationHint: locationHint ?? this.locationHint,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      creationMode: creationMode ?? this.creationMode,
      photos: photos ?? this.photos,
      verifiedOnSite: verifiedOnSite ?? this.verifiedOnSite,
      organizationId: organizationId ?? this.organizationId,
      trustLevel: trustLevel ?? this.trustLevel,
      deviceLocation: deviceLocation ?? this.deviceLocation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.jsonValue,
        'kind': kind.jsonValue,
        'lat': lat,
        'lng': lng,
        'address': address,
        'locationHint': locationHint,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'status': status.name.toUpperCase(),
        'creationMode': creationMode == CreationMode.gps ? 'GPS' : 'ADDRESS',
        'photos': photos,
        'verifiedOnSite': verifiedOnSite,
        'organizationId': organizationId,
        'trustLevel': trustLevel,
        'deviceLocation': deviceLocation?.toJson(),
      };
}

class DuplicateCheckResult {
  final bool hasDuplicates;
  final List<Panneau> duplicates;

  const DuplicateCheckResult({
    required this.hasDuplicates,
    this.duplicates = const [],
  });
}

class PanneauCreationPayload {
  final String title;
  final String description;
  final PanneauCategory category;
  final PanneauKind kind;
  final double lat;
  final double lng;
  final String address;
  final String locationHint;
  final DateTime startsAt;
  final DateTime endsAt;
  final CreationMode creationMode;
  final DeviceLocation? deviceLocation;
  final bool confirmDistinct;

  const PanneauCreationPayload({
    required this.title,
    required this.description,
    required this.category,
    required this.kind,
    required this.lat,
    required this.lng,
    required this.address,
    required this.locationHint,
    required this.startsAt,
    required this.endsAt,
    required this.creationMode,
    this.deviceLocation,
    this.confirmDistinct = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category.jsonValue,
        'kind': kind.jsonValue,
        'lat': lat,
        'lng': lng,
        'address': address,
        'locationHint': locationHint,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'creationMode': creationMode == CreationMode.gps ? 'GPS' : 'ADDRESS',
        'deviceLocation': deviceLocation?.toJson(),
        'confirmDistinct': confirmDistinct,
      };
}
