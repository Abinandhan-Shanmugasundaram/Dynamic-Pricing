import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/dynamic_pricing_service.dart';

class FareScreen extends StatefulWidget {
  const FareScreen({
    super.key,
    required this.distanceKm,
    required this.trafficFactor,
    required this.weatherFactor,
    required this.demandSupplyFactor,
  });

  final double? distanceKm;
  final double? trafficFactor;
  final String? weatherFactor;
  final double? demandSupplyFactor;

  @override
  _FareScreenState createState() => _FareScreenState();
}

class _FareScreenState extends State<FareScreen> {
  double? fare;
  String? message;
  bool isLoading = false;

  void fetchFare() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    int? batteryLevel = prefs.getInt('battery_percentage');

    var result = await FareService.getFareEstimate(
        distanceKm: widget.distanceKm,
        trafficFactor: widget.trafficFactor,
        weatherFactor: widget.weatherFactor,
        demandSupplyFactor: widget.demandSupplyFactor,
        batteryStatus: batteryLevel);

    setState(() {
      isLoading = false;
      if (result != null) {
        fare = result["predicted_fare"];
        message = result["message"];
      } else {
        message = "Failed to fetch fare.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Fare Estimate"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            const Text(
              "Your Fare Estimate",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // Fare Display
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    isLoading
                        ? "Calculating..."
                        : fare != null
                            ? "₹${fare!.toStringAsFixed(2)}"
                            : "Press the button to get fare",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (message != null)
                    Text(
                      message!,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Fetch Fare Button
            ElevatedButton(
              onPressed: isLoading ? null : fetchFare,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Get Fare Estimate",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
