// lib/services/api/soilo_api_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;

class SoiloApiService {
  final String baseUrl = kSoiloApiBaseUrl;

  /// Fetches the list of available crop options from the Flask backend.
  Future<List<String>> fetchCropOptions() async {
    final uri = Uri.parse('$baseUrl/required_inputs');

    try {
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? inputs = data['inputs'];

        if (inputs != null) {
          // Find the entry with id 'crop_type' and extract its options
          final cropInput = inputs.firstWhere(
                (input) => input['id'] == 'crop_type',
            orElse: () => null,
          );

          if (cropInput != null && cropInput['options'] is List) {
            return List<String>.from(cropInput['options']);
          }
        }
        throw Exception('Crop options not found or in unexpected format in API response.');
      } else {
        throw Exception('Failed to load crop options. Status: ${response.statusCode}');
      }
    } catch (e) {
      // General error handling (network issue, JSON decoding, etc.)
      throw Exception('Network or processing error fetching crops: $e');
    }
  }
}

final soiloApiServiceProvider = Provider((ref) => SoiloApiService());