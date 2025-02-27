import 'dart:convert';

import 'package:http/http.dart' as http;

Future<double?> getDistance(
    String origin, String destination, String apiKey) async {
  final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=$origin&destinations=$destination&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final distanceInMeters =
        data['rows'][0]['elements'][0]['distance']['value'];
    // Convert meters to kilometers
    return distanceInMeters / 1000;
  } else {
    print('Failed to fetch distance: ${response.statusCode}');
    return null;
  }
}
