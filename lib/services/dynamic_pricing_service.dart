import 'dart:convert';

import 'package:http/http.dart' as http;

class FareService {
  static const String _baseUrl = "http://127.0.0.1:5000";

  /// Fetches the dynamic fare estimate from the backend API
  static Future<Map<String, dynamic>?> getFareEstimate({
    required double? pickupLat,
    required double? pickupLng,
    required double? dropLat,
    required double? dropLng,
    required double? distanceKm,
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/calculate_fare");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pickup": {"lat": pickupLat, "lng": pickupLng},
          "drop": {"lat": dropLat, "lng": dropLng},
          "distance_km": distanceKm
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error fetching fare: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
