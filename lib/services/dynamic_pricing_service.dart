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
      final url = Uri.parse(
          urls.pricing); // Ensure it's "http://127.0.0.1:5000/predict"
      debugPrint("Pricing URL -> $url");
      String body =
          '{"distance_km": $distanceKm,"traffic_factor": $trafficFactor,"weather_factor": "Clear","demand_supply_factor": 1}';
      debugPrint("body vbhnjkjhg $body");
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
