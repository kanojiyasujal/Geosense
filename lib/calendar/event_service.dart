
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../Notifications/notification_service.dart';
import '../maps/radr_setting.dart';


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class EventCalendar extends StatefulWidget {
  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {

 

  @override
  void initState() {
    super.initState();
  
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
      ),
       body: Column(
        children: [
          SfCalendar(
            view: CalendarView.month,
            // Add your calendar customization here
          ),
          SizedBox(height: 16),
          Text(
            'Events:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: EventList(updateSoundMode: (bool ) {  },),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddEventPage(
              selectedLocation: LatLng(0, 0),
              selectedRadarRange: 1000, 
              updateSoundMode: (bool ) {  },
              
            ),
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class EventList extends StatelessWidget {
  final Function(bool) updateSoundMode;

  EventList({required this.updateSoundMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var events = snapshot.data?.docs.map((doc) {
          GeoPoint geoPoint = doc['location'];
          return Event(
            name: doc['name'],
            date: (doc['date'] as Timestamp).toDate(),
            color: Color(int.tryParse(doc['color']) ?? 0xFF000000),
            location: LatLng(
              geoPoint.latitude,
              geoPoint.longitude,
            ),
            radarRange: doc['radarRange'],
          );
        }).toList();

        return ListView.builder(
          itemCount: events?.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2.0,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.black.withOpacity(0.7),
              child: GestureDetector(
                onLongPress: () {
                  // Show a dialog to confirm the deletion
                  _showDeleteConfirmationDialog(context, events![index]);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: events![index].color,
                  ),
                  title: Text(
                    'Event: ${events[index].name.toString()}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${_formatDate(events[index].date)}',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        'Location: ${events[index].location.toString()}',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        'Radar Range: ${events[index].radarRange}',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Format the date as per your requirement
    return '${date.day}-${date.month}-${date.year}';
  }

  void _showDeleteConfirmationDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Call the function to delete the event from Firestore
                await _deleteEvent(event);


                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

Future<void> _deleteEvent(Event event) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('name', isEqualTo: event.name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        await FirebaseFirestore.instance.collection('events').doc(document.id).delete();
      }
      print('Events deleted successfully from Firestore.');

      // You can return a boolean indicating success if needed
      // return true;
      
    } else {
      print('No events found in Firestore with the given name.');
      // return false;
    }
  } catch (e) {
    print('Error deleting events from Firestore: $e');
    // return false;
  }
}

}
class Event {
  late String name;
  late DateTime date;
  late Color color;
  late LatLng location;
  late double radarRange;

  Event({
    required this.name,
    required this.date,
    required this.color,
    required this.location,
    required this.radarRange,
  });
}
class AddEventPage extends StatefulWidget {
  late final LatLng selectedLocation;
  final double selectedRadarRange;
  final Function(bool) updateSoundMode;

  AddEventPage({
    required this.selectedLocation,
    required this.selectedRadarRange,
    required this.updateSoundMode,
  });

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late TextEditingController eventNameController;
  late DateTime selectedDate;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController();
    selectedDate = DateTime.now();
    selectedColor = Colors.blue; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 16),
              Text('Event Date: ${selectedDate.toLocal()}'),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate)
                    setState(() {
                      selectedDate = pickedDate;
                    });
                },
                child: Text('Select Date'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Event Color:'),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _showColorPicker(context);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to SearchPlacesScreen to add event location
                  LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventService(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      widget.selectedLocation = result;
                    });
                  }
                },
                child: Text('Add Event Location'),
              ),
              SizedBox(height: 16),
              Text('Selected Location: ${widget.selectedLocation}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Save the event with all details
                  addEvent();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => EventCalendar()));
                },
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color; // Update the selected color in state
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void addEvent() async {
    Event newEvent = Event(
      name: eventNameController.text,
      date:  DateTime(selectedDate.year, selectedDate.month, selectedDate.day), // Remove time component
      color: selectedColor,
      location: widget.selectedLocation,
      radarRange: widget.selectedRadarRange,
    );

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'name': newEvent.name,
        'date': Timestamp.fromDate(newEvent.date),
        'color': newEvent.color.value.toString(), // Convert color to string representation
        'location': GeoPoint(newEvent.location.latitude, newEvent.location.longitude),
        'radarRange': newEvent.radarRange,
      });

      print('Event added successfully to Firestore.');

      // You can also call the function to update sound mode based on location here
      //updateSoundModeBasedOnLocation();
        // Call the callback function with true to indicate successful event addition
      widget.updateSoundMode(true);
     

    } catch (e) {
      print('Error adding event to Firestore: $e');
    }
  }
  
 
}






class EventService extends StatefulWidget {
  const EventService({Key? key}) : super(key: key);

  @override
  State<EventService> createState() => _EventServiceState();

  
  
}

const kGoogleApiKey = 'AIzaSyDSiCgGPGMrRY1HZ5cQuMAiYWK4NTJhPuI';

class _EventServiceState extends State<EventService> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);
  


   final NotificationService notificationService = NotificationService();
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  Set<Marker> markersList = {};
  Set<Circle> radarCircles = {};
  late GoogleMapController googleMapController;
  final Mode _mode = Mode.overlay;
  Prediction? _selectedPrediction;
  double radarRange = 1000; // Default radar range in meters
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _openDoNotDisturbSettings();
    _showCurrentLocation();
    checkForSavedLocations();
     FirebaseFirestore.instance.collection('location').snapshots().listen((event) {
    event.docChanges.forEach((change) {
      if (change.type == DocumentChangeType.removed) {
     updateSoundModeBasedOnLocation();
     //_addEventLocation(change.doc);

     
      }});});
    }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Google Search Places"),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
         
          SpeedDialChild(
            child: Icon(Icons.my_location),
            label: 'Current Location',
            onTap: () {
              _showCurrentLocation();
            },
          ),
          
          SpeedDialChild(
            child: Icon(Icons.settings),
            label: 'Radar Setting',
            onTap: () async {
              final updatedRadarRange = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RadarSettingsPage(
                    initialRadarRange: radarRange,
                  ),
                ),
              );
              if (updatedRadarRange != null) {
                setState(() {
                  radarRange = updatedRadarRange;
                });

                _updateRadarCircles();
              }
            },
          ),
    
          SpeedDialChild(
            child: Icon(Icons.add_rounded),
            label: 'Add Event Location',
            onTap: () {
              _handleSaveLocation();

            },
          ),
        ],
      ),
    
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: markersList,
              circles: radarCircles,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _handlePressButton(),
                  icon: Icon(Icons.search),
                  label: const Text("Search Places"),
                ),
              ),
            ),
          ],
        ),
      );
    
  }

  Future<void> _handlePressButton() async {
    _selectedPrediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: 'en',
      strictbounds: false,
      types: [""],
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      components: [
        Component(Component.country, "ind"),
        Component(Component.country, "usa"),
      ],
    );

    if (_selectedPrediction != null) {
      displayPrediction(_selectedPrediction!, homeScaffoldKey.currentState);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Text(response.errorMessage ?? 'Error'),
      ),
    );
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    currentLocation = LatLng(lat, lng);

    markersList.clear();
    markersList.add(
      Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name),
      ),
    );

    setState(() {});

    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
    );

    _updateRadarCircles();
  }

Future<void> _handleSaveLocation() async {
  if (currentLocation != null) {
    final name = _selectedPrediction?.description ?? 'Current Location';
    final address = _selectedPrediction?.structuredFormatting?.secondaryText ?? '';

    // Check if the location already exists in Firestore
    bool locationExists = await _checkIfLocationExists(currentLocation!);

    if (locationExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location already exists.'),
        ),
      );
    } else {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location selected successfully.'),
          ),
        );


        // Navigate to AddEventPage and pass the selected location, radar range, and callback function
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEventPage(
              selectedLocation: currentLocation!,
              selectedRadarRange: radarRange,
              updateSoundMode: (bool success) {
                if (success) {
                  // Call the function to update sound mode based on location here
                  updateSoundModeBasedOnLocation();
                }
              },
            ),
          ),
        );
      } catch (e) {
        print('Error saving location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save location.'),
          ),
        );
      }
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No location to save. Please search for a location.'),
      ),
    );
  }
}

  Future<bool> _checkIfLocationExists(LatLng location) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('lat', isEqualTo: location.latitude)
          .where('lng', isEqualTo: location.longitude)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if location exists: $e');
      return false;
    }
  }

  Future<void> _showCurrentLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Set _selectedPrediction to null when using "Current Location" button
        _selectedPrediction = null;

        // Center the map on the user's current location
        googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.0,
          ),
        );

        // Add a marker for the current location
        markersList.add(
          Marker(
            markerId: MarkerId("current_location"),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: "Current Location"),
          ),
        );

        setState(() {});

        // Use geocoding for reverse geocoding
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
          localeIdentifier: 'en_US',
        );

        if (placemarks.isNotEmpty) {
          final Placemark placemark = placemarks.first;
          final name = placemark.name ?? "No Name";
          final address = placemark.street ?? "No Address";

          _selectedPrediction = Prediction(description: '$name, $address');
        } else {
          _selectedPrediction = Prediction(description: "No Address Found");
        }

        _updateRadarCircles();

        setState(() {});

        // Save current location as a separate variable
        currentLocation = LatLng(position.latitude, position.longitude);
      } catch (e) {
        print('Error getting current location: $e');
      }
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
              'Please grant location permission in the device settings to use this feature.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
Future<void> _updateRadarCircles() async {
  radarCircles.clear();
  if (currentLocation != null) {
    radarCircles.add(
      Circle(
        circleId: CircleId('radar_circle_${currentLocation!.latitude}_${currentLocation!.longitude}'),
        center: currentLocation!,
        radius: radarRange,
        fillColor: Color.fromRGBO(0, 0, 255, 0.3),
        strokeWidth: 0,
      ),
    );
  }

  setState(() {
    updateSoundModeBasedOnLocation();
  });
}
Future<void> updateSoundModeBasedOnLocation() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    bool shouldMute = false; // Flag to track if the phone should be muted

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        double savedLat = document['location'].latitude;
        double savedLng = document['location'].longitude;
        double savedRadarRange = document['radarRange'];
        DateTime eventDate = (document['date'] as Timestamp).toDate();

        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          savedLat,
          savedLng,
        );

        print('Distance to event: $distance, Radar Range: $savedRadarRange');
        print('Event Date: $eventDate, Current Date: ${DateTime.now()}');

        print('Condition: ${distance < savedRadarRange && eventDate.isAfter(DateTime.now())}');
        
        // Check if the event is within the radar range and on the same date
        if (distance < savedRadarRange &&
            eventDate.year == DateTime.now().year &&
            eventDate.month == DateTime.now().month &&
            eventDate.day == DateTime.now().day) {
          shouldMute = true;
          break;
        }
      }
    }

    // Mute or unmute the phone based on the calculated shouldMute value
    if (shouldMute) {
      print('Should mute: $shouldMute');
      await _setSilentMode(); // Mute the phone
      print('Phone muted.');
    } else {
      print('No events or not in range, unmute the phone.');
      await _setNormalMode(); // Unmute the phone
      print('Phone unmuted.');
    }

  } catch (e) {
    print('Error updating sound mode based on location: $e');
  }
}



  RingerModeStatus _soundMode = RingerModeStatus.unknown;

Future<void> _setNormalMode() async {
  RingerModeStatus status;

  try {
    status = await SoundMode.setSoundMode(RingerModeStatus.normal);
    setState(() {
      _soundMode = status;
    });
    print('Phone unmuted.');
    notificationService.showSoundModeChangeNotification(false); // Notify that the phone is unmuted
  } on PlatformException {
    print('Error setting normal mode. Do Not Disturb access permissions required!');
  }
}

Future<void> _setSilentMode() async {
  RingerModeStatus status;

  try {
    status = await SoundMode.setSoundMode(RingerModeStatus.silent);
    if (status != RingerModeStatus.silent) {
      // Check if the current sound mode is not already silent
      status = await SoundMode.setSoundMode(RingerModeStatus.silent);
      setState(() {
        _soundMode = status;
      });
    }
    print('Phone muted. Status: $status');
    notificationService.showSoundModeChangeNotification(true); // Notify that the phone is muted
  } on PlatformException {
    print('Error setting silent mode. Do Not Disturb access permissions required!');
  }
}


  Future<void> _openDoNotDisturbSettings() async {
    bool? isGranted = await PermissionHandler.permissionsGranted;

    if (!isGranted!) {
      await PermissionHandler.openDoNotDisturbSetting();
    }
  }

Future<void> checkForSavedLocations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('events').get();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          double savedLat = document['location'].latitude;
          double savedLng = document['location'].longitude;
          double radarRange = document['radarRange'];

          // Update sound mode based on saved locations
          await updateSoundModeBasedOnLocation();
        }
      }
    } catch (e) {
      print('Error checking for saved locations: $e');
    }
  }



}