import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RadarSettingsPage extends StatefulWidget {
  final double initialRadarRange;

  RadarSettingsPage({required this.initialRadarRange});

  @override
  _RadarSettingsPageState createState() => _RadarSettingsPageState();
}

class _RadarSettingsPageState extends State<RadarSettingsPage> {
  double radarRange = 1000; // Default radar range in meters

  @override
  void initState() {
    super.initState();
    radarRange = widget.initialRadarRange; // Set the initial radar range
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radar Settings'),
      ),
      body:Stack(
        children: [
          Image.asset(
            'assets/images/directions-concept-illustration_114360-3193-removebg-preview.png',
            fit: BoxFit.contain, // You can adjust the fit as needed
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.withOpacity(0.3),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Radar Range (in meters):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Slider(
                    value: radarRange,
                    onChanged: (newValue) {
                      setState(() {
                        radarRange = newValue;
                      });
                    },
                    min: 100, // Adjust minimum range as needed
                    max: 5000, // Adjust maximum range as needed
                    divisions: 50, // Adjust divisions as needed
                    label: radarRange.round().toString(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Hero(
              tag: 'save_button',
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, radarRange);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}