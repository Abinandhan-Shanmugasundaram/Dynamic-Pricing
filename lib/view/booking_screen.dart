import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:major_project/assets/constants.dart';
import 'package:major_project/view/book_taxi_screen.dart';
import 'package:major_project/view/drop_location_screen.dart';
import 'package:major_project/view/pickup_location_screen.dart';

import '../services/traffic_service.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late String pickupAddress = '';
  late String dropAddress = '';
  double? distance;
  double? fare = 0.0;
  double pickupLat = 0.0;
  double pickupLon = 0.0;
  double dropLat = 0.0;
  double dropLon = 0.0;

  late TrafficService trafficService;

  @override
  void initState() {
    super.initState();
    trafficService =
        TrafficService(googleMapApi); // Initialize TrafficService with API key
  }

  void _selectPickup() async {
    final selectedPickup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PickupLocationScreen()),
    );

    if (selectedPickup != null) {
      setState(() {
        pickupAddress = selectedPickup["address"];
        pickupLat = selectedPickup["latitude"];
        pickupLon = selectedPickup["longitude"];
      });
      _calculateDistanceAndFare();
    }
  }

  void _selectDrop() async {
    final selectedDrop = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DropLocationScreen()),
    );

    if (selectedDrop != null) {
      setState(() {
        dropAddress = selectedDrop["address"];
        dropLat = selectedDrop["latitude"];
        dropLon = selectedDrop["longitude"];
      });
      _calculateDistanceAndFare();
    }
  }

  double calculateBaseFare(
      double trafficFactor, double demandSupplyFactor, double weatherFactor) {
    const double minBaseFare = 30.0; // Minimum base fare
    const double maxBaseFare = 100.0; // Maximum base fare

    // Base fare varies based on external factors
    double baseFare = minBaseFare *
        (1 +
            (trafficFactor - 1) +
            (demandSupplyFactor - 1) +
            (weatherFactor - 1));

    // Ensure base fare is within limits
    return baseFare.clamp(minBaseFare, maxBaseFare);
  }

  Future<void> _calculateDistanceAndFare() async {
    if (pickupAddress != null && dropAddress != null) {
      const String googleApiKey = googleMapApi;

      // Get distance
      final distanceInKm = await getDistance(
          pickupLat, pickupLon, dropLat, dropLon, googleApiKey);

      // Get traffic data
      final trafficData =
          await trafficService.getTraffic(pickupAddress!, dropAddress!);
      final trafficFactor = trafficData['routes'][0]['legs'][0]
              ['duration_in_traffic']['value'] /
          trafficData['routes'][0]['legs'][0]['duration']['value'];

      // Get demand and supply data (Simulated API call for now)
      final demandSupplyFactor =
          await getDemandSupplyFactor(pickupAddress!, dropAddress!);

      // Get weather data (Simulated API call for now)
      final weatherFactor = await getWeatherFactor(pickupAddress!);

      // Calculate dynamic base fare
      final baseFare =
          calculateBaseFare(trafficFactor, demandSupplyFactor, weatherFactor);

      // Calculate final fare
      final calculatedFare = calculateDynamicFare(
          distanceInKm!, weatherFactor, trafficFactor, baseFare);

      setState(() {
        distance = distanceInKm;
        fare = calculatedFare;
      });
    }
  }

  Future<double> getDemandSupplyFactor(String pickup, String drop) async {
    // Simulate demand-supply factor (1.0 = normal, >1.0 = high demand)
    return 1.2; // Example: 20% higher fare due to high demand
  }

  Future<double> getWeatherFactor(String location) async {
    // Simulate weather impact (1.0 = normal, >1.0 = bad weather)
    return 1.1; // Example: 10% higher fare due to rain
  }

  Future<double> getDistance(double pickupLat, double pickupLon, double dropLat,
      double dropLon, String apiKey) async {
    final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$pickupLat,$pickupLon&destinations=$dropLat,$dropLon&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distanceInMeters =
          data['rows'][0]['elements'][0]['distance']['value'];
      return distanceInMeters / 1000; // Convert meters to kilometers
    } else {
      throw Exception('Failed to fetch distance');
    }
  }

  double calculateDynamicFare(double distanceInKm, double weatherFactor,
      double trafficFactor, double baseFare) {
    const double perKmRate = 10.0; // Fare per kilometer

    double fare = baseFare + (distanceInKm * perKmRate);
    fare *= weatherFactor;
    fare *= trafficFactor;

    return fare;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Ride")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Pickup Location"),
              subtitle: Text(pickupAddress ?? "Select pickup location"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: _selectPickup,
            ),
            const Divider(),
            ListTile(
              title: const Text("Drop Location"),
              subtitle: Text(dropAddress ?? "Select drop location"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: _selectDrop,
            ),
            const Divider(),
            if (distance != null)
              Text('Distance: ${distance!.toStringAsFixed(2)} km'),
            if (fare != null) Text('Total Fare: ₹${fare!.toStringAsFixed(2)}'),
            const Spacer(),
            if (pickupAddress != null && dropAddress != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FareScreen(
                              pickupLat: pickupLat,
                              pickupLng: pickupLon,
                              dropLat: dropLat,
                              dropLng: dropLon,
                              distanceKm: distance,
                            )),
                  );
                },
                child: const Text("Confirm Ride"),
              ),
          ],
        ),
      ),
    );
  }
}
