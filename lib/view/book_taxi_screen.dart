import 'package:flutter/material.dart';

import '../services/dynamic_pricing_service.dart';

class FareScreen extends StatefulWidget {
  FareScreen({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.distanceKm,
  });
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final double? distanceKm;

  @override
  _FareScreenState createState() => _FareScreenState();
}

class _FareScreenState extends State<FareScreen> {
  double? fare;
  double? trafficFactor;
  double? weatherFactor;
  double? demandSupplyFactor;

  void fetchFare() async {
    var result = await FareService.getFareEstimate(
      pickupLat: widget.pickupLat,
      pickupLng: widget.pickupLng,
      dropLat: widget.dropLat,
      dropLng: widget.dropLng,
      distanceKm: widget.distanceKm,
    );

    if (result != null) {
      setState(() {
        fare = result["fare"];
        trafficFactor = result["traffic_factor"];
        weatherFactor = result["weather_factor"];
        demandSupplyFactor = result["demand_supply_factor"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dynamic Fare Estimate")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Fare: ₹${fare ?? 'Loading...'}"),
            Text("Traffic Factor: ${trafficFactor ?? '-'}"),
            Text("Weather Factor: ${weatherFactor ?? '-'}"),
            Text("Demand-Supply Factor: ${demandSupplyFactor ?? '-'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchFare,
              child: Text("Get Fare Estimate"),
            ),
          ],
        ),
      ),
    );
  }
}
