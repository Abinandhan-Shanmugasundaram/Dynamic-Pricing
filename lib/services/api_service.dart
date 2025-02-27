import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; // Change to server IP if needed

  /// **Fetch dynamic pricing from API**
  static Future<Map<String, dynamic>?> fetchPricing(
      {required String cityId}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/pricing/$cityId"),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching pricing: $e");
      return null;
    }
  }

  /// **Send request to predict dynamic fare**
  static Future<Map<String, dynamic>?> predictFare({
    required String cityId,
    required int demand,
    required int supply,
    required String weather,
    required String traffic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "city_id": cityId,
          "demand": demand,
          "supply": supply,
          "weather": weather,
          "traffic": traffic
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Error predicting fare: $e");
      return null;
    }
  }
}
