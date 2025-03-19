import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:major_project/res/urls.dart';

class FareService {
  /// Fetches the dynamic fare estimate from the backend API
  static Future<Map<String, dynamic>?> getFareEstimate({
    required double? distanceKm,
    required double? trafficFactor,
    required String? weatherFactor,
    required double? demandSupplyFactor,
  }) async {
    try {
      final url = Uri.parse(urls.pricing);
      debugPrint("Pricing URL -> $url");

      // 🌦️ Map weather string to float value
      final weatherMap = {
        "Clear": 1.0,
        "Rainy": 1.2,
        "Foggy": 1.3,
        "Stormy": 1.5,
        "Snowy": 1.7,
      };

      final weatherFloat = weatherMap[weatherFactor ?? "Clear"] ?? 1.0;

      String body = jsonEncode({
        "distance_km": distanceKm,
        "traffic_factor": trafficFactor,
        "weather_factor": weatherFloat,
        "demand_supply_factor": demandSupplyFactor,
      });

      debugPrint("Request Body: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint("Response: ${response.body}");
        return jsonDecode(response.body);
      } else {
        debugPrint("Error fetching fare: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }
}
