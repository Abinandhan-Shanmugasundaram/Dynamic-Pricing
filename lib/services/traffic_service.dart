import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../res/urls.dart';

class TrafficService {
  final String apiKey;

  TrafficService(this.apiKey);

  Future<Map<String, dynamic>> getTraffic(
      double picklat, double picklon, double droplat, double droplon) async {
    final url = '${urls.trafficDetails}'
        '?origin=$picklat,$picklon&destination=$droplat,$droplon&departure_time=now&key=$apiKey';

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
