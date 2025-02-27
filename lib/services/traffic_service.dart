import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class TrafficService {
  final String apiKey;

  TrafficService(this.apiKey);

  Future<Map<String, dynamic>> getTraffic(
      String origin, String destination) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin&destination=$destination&departure_time=now&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    debugPrint(response.body);
    debugPrint("Traffic URL -> $url");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch traffic data');
    }
  }
}
