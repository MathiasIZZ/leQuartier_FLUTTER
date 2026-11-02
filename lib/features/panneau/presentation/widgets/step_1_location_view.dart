import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:le_quartier/core/services/geocoding_service.dart';
import '../../domain/models/panneau.dart';
import '../providers/panneau_draft_provider.dart';

class Step1LocationView extends ConsumerStatefulWidget {
  const Step1LocationView({super.key});

  @override
  ConsumerState<Step1LocationView> createState() => _Step1LocationViewState();
}

class _Step1LocationViewState extends ConsumerState<Step1LocationView> {
  final MapController _mapController = MapController();
  final TextEditingController _addressSearchController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();

  List<AddressSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  String? _gpsMessage;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(panneauDraftProvider);
    _addressSearchController.text = draft.address;
    _hintController.text = draft.locationHint;
  }

  @override
  void dispose() {
    _addressSearchController.dispose();
    _hintController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().length < 3) {
        setState(() => _suggestions = []);
        return;
      }
      setState(() => _isSearching = true);
      final geocoding = ref.read(geocodingServiceProvider);
      final results = await geocoding.searchAddresses(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _handleGpsSelection() async {
    ref.read(panneauDraftProvider.notifier).setCreationMode(CreationMode.gps);
    setState(() => _gpsMessage = 'Recherche de votre position GPS...');
    
    final error = await ref.read(panneauDraftProvider.notifier).acquireGpsLocation();
    final draft = ref.read(panneauDraftProvider);

    if (error != null) {
      setState(() => _gpsMessage = error);
    } else {
      _mapController.move(LatLng(draft.lat, draft.lng), 16.0);
      
      final geocoding = ref.read(geocodingServiceProvider);
      final addressLabel = await geocoding.reverseGeocode(draft.lat, draft.lng);
      if (addressLabel != null && mounted) {
        ref.read(panneauDraftProvider.notifier).updateLocation(
          lat: draft.lat,
          lng: draft.lng,
          address: addressLabel,
          deviceLocation: draft.deviceLocation,
        );
        _addressSearchController.text = addressLabel;
      }

      String msg = 'Position GPS acquise.';
      if (draft.deviceLocation != null && draft.deviceLocation!.accuracy > 50) {
        msg += ' Attention : précision faible (${draft.deviceLocation!.accuracy.toStringAsFixed(0)}m). Ajustez le pin si besoin.';
      }
      setState(() => _gpsMessage = msg);
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      final center = camera.center;
      ref.read(panneauDraftProvider.notifier).updateLocation(
        lat: center.latitude,
        lng: center.longitude,
        address: ref.read(panneauDraftProvider).address,
        deviceLocation: ref.read(panneauDraftProvider).deviceLocation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(panneauDraftProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Où se situe l’événement ?',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          SegmentedButton<CreationMode>(
            segments: const [
              ButtonSegment(
                value: CreationMode.gps,
                label: Text('Ici (GPS)'),
                icon: Icon(Icons.my_location),
              ),
              ButtonSegment(
                value: CreationMode.address,
                label: Text('Ailleurs (Adresse)'),
                icon: Icon(Icons.search),
              ),
            ],
            selected: {draft.creationMode},
            onSelectionChanged: (Set<CreationMode> newSelection) {
              final mode = newSelection.first;
              ref.read(panneauDraftProvider.notifier).setCreationMode(mode);
              if (mode == CreationMode.gps) {
                _handleGpsSelection();
              } else {
                ref.read(panneauDraftProvider.notifier).updateLocation(
                  lat: draft.lat,
                  lng: draft.lng,
                  address: draft.address,
                  clearDeviceLocation: true,
                );
              }
            },
          ),
          const SizedBox(height: 16),

          if (draft.creationMode == CreationMode.gps) ...[
            ElevatedButton.icon(
              onPressed: _handleGpsSelection,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Actualiser ma position GPS'),
            ),
            if (_gpsMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _gpsMessage!,
                style: TextStyle(
                  color: draft.deviceLocation != null && draft.deviceLocation!.accuracy > 50
                      ? Colors.orange.shade800
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ] else ...[
            TextField(
              controller: _addressSearchController,
              decoration: InputDecoration(
                labelText: 'Rechercher une adresse',
                hintText: 'Ex: 15 rue Nationale, Tours',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion.label),
                      dense: true,
                      onTap: () {
                        _addressSearchController.text = suggestion.label;
                        setState(() => _suggestions = []);
                        ref.read(panneauDraftProvider.notifier).updateLocation(
                          lat: suggestion.lat,
                          lng: suggestion.lng,
                          address: suggestion.label,
                          clearDeviceLocation: true,
                        );
                        _mapController.move(LatLng(suggestion.lat, suggestion.lng), 16.0);
                      },
                    );
                  },
                ),
              ),
          ],
          const SizedBox(height: 16),

          Text(
            'Ajustez le pin sur la carte :',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(draft.lat, draft.lng),
                      initialZoom: 15.0,
                      onPositionChanged: _onMapPositionChanged,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.le_quartier',
                      ),
                    ],
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _hintController,
            decoration: const InputDecoration(
              labelText: 'Précision du lieu (optionnel)',
              hintText: 'Ex: Devant la boulangerie, 2e étage...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info_outline),
            ),
            onChanged: (val) {
              ref.read(panneauDraftProvider.notifier).updateLocationHint(val);
            },
          ),
        ],
      ),
    );
  }
}
