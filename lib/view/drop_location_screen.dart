import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:major_project/assets/constants.dart';

class DropLocationScreen extends StatefulWidget {
  @override
  _DropLocationScreenState createState() => _DropLocationScreenState();
}

class _DropLocationScreenState extends State<DropLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  GooglePlace googlePlace = GooglePlace(googleMapApi);
  TextEditingController searchController = TextEditingController();
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
  }

  void _searchLocation(String input) async {
    var result = await googlePlace.autocomplete.get(input);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void _selectLocation(AutocompletePrediction prediction) async {
    searchController.text = prediction.description!;
    var locations = await locationFromAddress(prediction.description!);

    if (locations.isNotEmpty) {
      setState(() {
        _selectedLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        _selectedAddress = prediction.description;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _selectedAddress != null) {
      Navigator.pop(context, {
        "address": _selectedAddress!,
        "latitude": _selectedLocation!.latitude,
        "longitude": _selectedLocation!.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Drop Location")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchLocation,
              decoration: const InputDecoration(
                labelText: "Search drop location",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:
                        _selectedLocation ?? const LatLng(37.7749, -122.4194),
                    zoom: 14,
                  ),
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: _selectedLocation!,
                          )
                        }
                      : {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                if (predictions.isNotEmpty)
                  Positioned(
                    top: 70,
                    left: 10,
                    right: 10,
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(predictions[index].description!),
                            onTap: () => _selectLocation(predictions[index]),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _confirmLocation,
            child: const Text("Confirm Drop Location"),
          ),
        ],
      ),
    );
  }
}
