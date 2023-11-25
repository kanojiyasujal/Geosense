import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationDetailPage extends StatelessWidget {
  final String name;
  final String address;
  final double? lat;
  final double? lng;

  LocationDetailPage({required this.name, required this.address, this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat ?? 0.0, lng ?? 0.0), // Use lat and lng, or default to (0,0)
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('location_marker'),
                  position: LatLng(lat ?? 0.0, lng ?? 0.0), // Use lat and lng, or default to (0,0)
                  infoWindow: InfoWindow(title: name, snippet: address),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: $name',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Address: $address',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
