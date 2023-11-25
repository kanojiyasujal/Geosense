import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rive_animation/battery_management/whitelist_contacts.dart';

import 'saved_messages.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BatteryIndicator(),
    );
  }
}

class BatteryIndicator extends StatefulWidget {
  @override
  _BatteryIndicatorState createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Battery _battery;
  int _batteryLevel = 0;
  double _batteryThreshold = 50.0; // Initial threshold value
  String _customMessage = '';
  TextEditingController _customMessageController = TextEditingController();

  List<String> _suggestedMessages = [
    'Battery is low, please charge soon.',
    'Running out of battery!',
    'Battery level critical!',
  ];

  String _selectedSuggestion = ''; // Provide an initial value

  late CollectionReference _batteryCollection;

  @override
  void initState() {
    super.initState();

    _battery = Battery();

    // Initialize _batteryCollection here
    _batteryCollection = FirebaseFirestore.instance.collection('battery_data');

    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Uncomment the line below to start the animation automatically
    _animationController.forward();

    // Start a periodic timer to refresh battery level every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) {
      _getBatteryLevel();
    });

    // Get the initial battery level
    _getBatteryLevel();

    // Ensure there's an initial value for _selectedSuggestion
    if (_suggestedMessages.isNotEmpty) {
      _selectedSuggestion = _suggestedMessages.first;
    }
  }

  Future<void> _getBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _batteryLevel = batteryLevel;
        });
      }
    } catch (e) {
      print("Error fetching battery level: $e");
    }
  }

  void _onThresholdChanged(double value) {
    setState(() {
      _batteryThreshold = value;
    });
  }

  void _onSaveMessagePressed() async {
    // Save data to Firestore
    await _batteryCollection.add({
      'batteryThreshold': _batteryThreshold.toInt(),
      'customMessage': _customMessageController.text,
    });
     ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('message saved successfully.'),
          ),
        );
    // Update the local state
    setState(() {
      _customMessage = _customMessageController.text;
    });
  }

  void _onSuggestionChanged(String? value) {
    if (value != null && mounted) {
      setState(() {
        _selectedSuggestion = value;
        // Set the selected suggestion to your custom message field or perform other actions.
        _customMessageController.text = value;
      });
    }
  }

  void _redirectToAnotherScreen() {
    // Use Navigator to push a new screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedMessagesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Battery Indicator'),
         actions: [
    IconButton(
      icon: Icon(Icons.contacts),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WhitelistContactsPage()),
        );
      },
    ),
  ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 200 * (_batteryLevel / 100),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$_batteryLevel%',
                          style: TextStyle(
                            color: Color.fromARGB(255, 19, 12, 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.black.withOpacity(0.7),
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Battery Threshold: ${_batteryThreshold.toInt()}%',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue.shade600,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: Colors.blue.shade600,
                        overlayColor: Color.fromARGB(255, 28, 53, 151).withOpacity(0.3),
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
                      ),
                      child: Slider(
                        value: _batteryThreshold,
                        min: 0.0,
                        max: 100.0,
                        onChanged: _onThresholdChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customized Message:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _customMessageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your customized message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _selectedSuggestion,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.black),
                        onChanged: _onSuggestionChanged,
                        items: _suggestedMessages.map((String suggestion) {
                          return DropdownMenuItem<String>(
                            value: suggestion,
                            child: Text(suggestion),
                          );
                        }).toList(),
                        hint: Text(
                          'Select or type a custom message...',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSaveMessagePressed,
              child: Text('Save Message'),
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _redirectToAnotherScreen,
        tooltip: 'Go to Another Screen',
        child: Icon(Icons.message_outlined),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}