import 'package:flutter/material.dart';
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
  String pickupAddress = 'Select Pickup location';
  String dropAddress = 'Select Drop location';
  double distanceInKm = 0.0;
  double? fare = 0.0;
  double pickupLat = 0.0;
  double pickupLon = 0.0;
  double dropLat = 0.0;
  double dropLon = 0.0;
  double normalizedTrafficFactor = 0.0;

  late TrafficService trafficService;

  @override
  void initState() {
    super.initState();
    ();
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
      _calculateDistance();
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
      _calculateDistance();
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

  Future<void> _calculateDistance() async {
    try {
      // Fetch Traffic Data
      final trafficData = await trafficService.getTraffic(
          pickupLat, pickupLon, dropLat, dropLon);

      // Safety check: Ensure response contains expected fields
      if (trafficData.containsKey('routes') &&
          (trafficData['routes'] as List).isNotEmpty &&
          (trafficData['routes'][0]['legs'] as List).isNotEmpty) {
        final leg = trafficData['routes'][0]['legs'][0];

        // Extract Distance (convert from meters to km)
        distanceInKm = leg['distance']['value'] / 1000.0;

        // Extract Duration
        final int durationInSeconds = leg['duration']['value'];
        final int durationInTrafficSeconds =
            leg['duration_in_traffic']['value'];

        // Calculate Traffic Factor
        const double minTraffic = 0.5; // Minimum expected traffic factor
        const double maxTraffic = 2.0; // Maximum expected traffic factor
        double trafficFactor = durationInTrafficSeconds / durationInSeconds;
        trafficFactor = trafficFactor.clamp(minTraffic, maxTraffic);
        normalizedTrafficFactor =
            1 + (trafficFactor - minTraffic) / (maxTraffic - minTraffic);

        debugPrint("Traffic Factor: $trafficFactor");
        debugPrint("Normalized Traffic Factor: $normalizedTrafficFactor");
        debugPrint("distanceInKm Traffic Factor: $distanceInKm");

        // Get Demand-Supply Factor (API Call)
        // double demandSupplyFactor =
        //     await getDemandSupplyFactor(pickupAddress, dropAddress);

        // Get Weather Factor (API Call)
        // double weatherFactor = await getWeatherFactor(pickupAddress);

        // Calculate Base Fare
        // double baseFare = calculateBaseFare(
        //     normalizedTrafficFactor, demandSupplyFactor, weatherFactor);

        // Calculate Final Fare
        // double calculatedFare = calculateDynamicFare(
        //     distanceInKm, weatherFactor, normalizedTrafficFactor, baseFare);

        // Store Data and Update UI

        // debugPrint("Final Fare: ₹${calculatedFare.toStringAsFixed(2)}");
      } else {
        throw Exception("Invalid traffic data response: No routes found");
      }
    } catch (e) {
      debugPrint("Error fetching fare: $e");
    }
    setState(() {
      distanceInKm;
    });
  }

  // Future<double> getDemandSupplyFactor(String pickup, String drop) async {
  //   // Simulate demand-supply factor (1.0 = normal, >1.0 = high demand)
  //   return 1.2; // Example: 20% higher fare due to high demand
  // }
  //
  // Future<double> getWeatherFactor(String location) async {
  //   // Simulate weather impact (1.0 = normal, >1.0 = bad weather)
  //   return 1.1; // Example: 10% higher fare due to rain
  // }

  // Future<double> getDistance(double pickupLat, double pickupLon, double dropLat,
  //     double dropLon, String apiKey) async {
  //   final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
  //       '?origins=$pickupLat,$pickupLon&destinations=$dropLat,$dropLon&key=$apiKey';
  //
  //   final response = await http.get(Uri.parse(url));
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final distanceInMeters =
  //         data['rows'][0]['elements'][0]['distance']['value'];
  //     return distanceInMeters / 1000; // Convert meters to kilometers
  //   } else {
  //     throw Exception('Failed to fetch distance');
  //   }
  // }

  // double calculateDynamicFare(double distanceInKm, double weatherFactor,
  //     double trafficFactor, double baseFare) {
  //   const double perKmRate = 10.0; // Fare per kilometer
  //
  //   double fare = baseFare + (distanceInKm * perKmRate);
  //   fare *= weatherFactor;
  //   fare *= trafficFactor;
  //
  //   return fare;
  // }

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
            Text('Distance: $distanceInKm km'),
            Text('Traffic Factor: $normalizedTrafficFactor'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _calculateDistance();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FareScreen(
                            distanceKm: distanceInKm,
                            trafficFactor: normalizedTrafficFactor,
                            weatherFactor: 'Rainy',
                            demandSupplyFactor: 1.0,
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
