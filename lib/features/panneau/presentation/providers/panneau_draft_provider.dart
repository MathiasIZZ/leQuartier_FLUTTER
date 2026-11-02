import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/panneau.dart';
import '../../domain/repositories/panneau_repository.dart';
import '../../data/repositories/panneau_repository_impl.dart';

class PanneauDraftState {
  final int currentStep;
  final CreationMode creationMode;
  final double lat;
  final double lng;
  final String address;
  final String locationHint;
  final DeviceLocation? deviceLocation;
  
  final PanneauCategory? category;
  final PanneauKind kind;
  final DuplicateCheckResult? duplicateResult;
  bool isCheckingDuplicates;

  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;

  final bool isLoading;
  final String? errorMessage;
  final Panneau? createdPanneau;

  PanneauDraftState({
    this.currentStep = 0,
    this.creationMode = CreationMode.gps,
    this.lat = 47.3900, // Tours default
    this.lng = 0.6900,
    this.address = 'Tours, France',
    this.locationHint = '',
    this.deviceLocation,
    this.category,
    this.kind = PanneauKind.event,
    this.duplicateResult,
    this.isCheckingDuplicates = false,
    this.title = '',
    this.description = '',
    DateTime? startsAt,
    DateTime? endsAt,
    this.isLoading = false,
    this.errorMessage,
    this.createdPanneau,
  })  : startsAt = startsAt ?? DateTime.now().add(const Duration(hours: 1)),
        endsAt = endsAt ?? DateTime.now().add(const Duration(hours: 4));

  PanneauDraftState copyWith({
    int? currentStep,
    CreationMode? creationMode,
    double? lat,
    double? lng,
    String? address,
    String? locationHint,
    DeviceLocation? deviceLocation,
    bool clearDeviceLocation = false,
    PanneauCategory? category,
    PanneauKind? kind,
    DuplicateCheckResult? duplicateResult,
    bool? isCheckingDuplicates,
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? isLoading,
    String? errorMessage,
    Panneau? createdPanneau,
  }) {
    return PanneauDraftState(
      currentStep: currentStep ?? this.currentStep,
      creationMode: creationMode ?? this.creationMode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      locationHint: locationHint ?? this.locationHint,
      deviceLocation: clearDeviceLocation ? null : (deviceLocation ?? this.deviceLocation),
      category: category ?? this.category,
      kind: kind ?? this.kind,
      duplicateResult: duplicateResult ?? this.duplicateResult,
      isCheckingDuplicates: isCheckingDuplicates ?? this.isCheckingDuplicates,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      createdPanneau: createdPanneau ?? this.createdPanneau,
    );
  }
}

class PanneauDraftNotifier extends StateNotifier<PanneauDraftState> {
  final PanneauRepository _repository;

  PanneauDraftNotifier(this._repository) : super(PanneauDraftState());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setCreationMode(CreationMode mode) {
    state = state.copyWith(creationMode: mode);
  }

  void updateLocation({
    required double lat,
    required double lng,
    required String address,
    DeviceLocation? deviceLocation,
    bool clearDeviceLocation = false,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      address: address,
      deviceLocation: deviceLocation,
      clearDeviceLocation: clearDeviceLocation,
    );
  }

  void updateLocationHint(String hint) {
    state = state.copyWith(locationHint: hint);
  }

  void setCategory(PanneauCategory category) {
    state = state.copyWith(category: category);
  }

  void setKind(PanneauKind kind) {
    state = state.copyWith(kind: kind);
  }

  void updateDetails({
    required String title,
    required String description,
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    state = state.copyWith(
      title: title,
      description: description,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  Future<void> checkDuplicates() async {
    if (state.category == null || state.title.trim().isEmpty) return;
    
    state = state.copyWith(isCheckingDuplicates: true, errorMessage: null);
    try {
      final result = await _repository.checkDuplicates(
        lat: state.lat,
        lng: state.lng,
        category: state.category!,
        title: state.title,
      );
      state = state.copyWith(
        duplicateResult: result,
        isCheckingDuplicates: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingDuplicates: false,
        errorMessage: 'Erreur lors de la vérification des doublons',
      );
    }
  }

  Future<bool> publishPanneau({bool confirmDistinct = false}) async {
    if (state.category == null || state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Veuillez remplir les champs obligatoires');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final payload = PanneauCreationPayload(
        title: state.title.trim(),
        description: state.description.trim(),
        category: state.category!,
        kind: state.kind,
        lat: state.lat,
        lng: state.lng,
        address: state.address,
        locationHint: state.locationHint.trim(),
        startsAt: state.startsAt,
        endsAt: state.endsAt,
        creationMode: state.creationMode,
        deviceLocation: state.deviceLocation,
        confirmDistinct: confirmDistinct,
      );

      final created = await _repository.createPanneau(payload);
      state = state.copyWith(
        isLoading: false,
        createdPanneau: created,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Échec de la publication. Vérifiez votre connexion.',
      );
      return false;
    }
  }

  Future<String?> acquireGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Le service de localisation est désactivé.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Permission de localisation refusée.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Permissions de localisation refusées définitivement.';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final deviceLoc = DeviceLocation(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        isMocked: position.isMocked,
      );

      state = state.copyWith(
        lat: position.latitude,
        lng: position.longitude,
        deviceLocation: deviceLoc,
      );
      return null;
    } catch (e) {
      return 'Impossible de récupérer la position GPS.';
    }
  }
}

final panneauDraftProvider =
    StateNotifierProvider<PanneauDraftNotifier, PanneauDraftState>((ref) {
  final repo = ref.watch(panneauRepositoryProvider);
  return PanneauDraftNotifier(repo);
});
