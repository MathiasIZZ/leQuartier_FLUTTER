import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressSuggestion {
  final String label;
  final String name;
  final double lat;
  final double lng;
  final String? city;
  final String? postcode;

  const AddressSuggestion({
    required this.label,
    required this.name,
    required this.lat,
    required this.lng,
    this.city,
    this.postcode,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    return AddressSuggestion(
      label: properties['label'] ?? '',
      name: properties['name'] ?? '',
      lng: (coordinates[0] as num).toDouble(),
      lat: (coordinates[1] as num).toDouble(),
      city: properties['city'],
      postcode: properties['postcode'],
    );
  }
}

class GeocodingService {
  final Dio _dio;

  GeocodingService(this._dio);

  /// Search addresses using Base Adresse Nationale (BAN) API
  Future<List<AddressSuggestion>> searchAddresses(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final response = await _dio.get(
        'https://api-adresse.data.gouv.fr/search/',
        queryParameters: {
          'q': query,
          'limit': 5,
          'lat': 47.39, // Bias towards Tours
          'lon': 0.69,
        },
      );

      final features = response.data['features'] as List<dynamic>? ?? [];
      return features.map((f) => AddressSuggestion.fromJson(f)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Reverse geocoding to get address label from lat/lng
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://api-adresse.data.gouv.fr/reverse/',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'limit': 1,
        },
      );

      final features = response.data['features'] as List<dynamic>? ?? [];
      if (features.isNotEmpty) {
        final properties = features.first['properties'] as Map<String, dynamic>?;
        return properties?['label'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService(Dio());
});
