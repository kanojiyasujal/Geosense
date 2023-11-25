import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../battery_management/battery_ui.dart';
import '../../../calendar/event_service.dart';
import '../../../maps/unmut_mute.dart';



class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _rating = 1.0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          _showFeedbackDialog(context);
          // Prevent the default back button behavior
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              buildImageCard(),
              buildImageCard2(),
              buildImageCard1(),
            ],
          ),
        ),
      );

  Widget buildImageCard() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Ink.image(
              image: NetworkImage(
                  'https://img.freepik.com/free-vector/digital-gps-application-smartphones-geotag-sign-city-map-local-search-optimization-search-engine-targeting-local-seo-strategy-concept_335657-1207.jpg?w=996&t=st=1698695051~exp=1698695651~hmac=e4bc492fdbc7e68d813000fdf45c3f70c36b8ffc13c6517e0ce237da64d391ea'),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPlacesScreen()),
                  );
                },
              ),
              height: 240,
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 26, 140, 255).withOpacity(0.6),
              ),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Mute & Unmute',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildImageCard1() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Ink.image(
              image: NetworkImage(
                  'https://img.freepik.com/free-vector/time-management-marketers-teamwork_335657-3008.jpg?w=996&t=st=1698691602~exp=1698692202~hmac=92b94e17a41c2b3d16698607b6b24f2ffbb5da0c6f792c35d02cc22a264d6783'),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventCalendar()),
                  );
                },
              ),
              height: 240,
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 123, 63, 191).withOpacity(0.6),
              ),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Pre-schedule Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildImageCard2() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Ink.image(
              image: NetworkImage(
                  'https://img.freepik.com/premium-vector/battery-charge-tiny-users-battery-performance-long-life-battery-energy-power-source-maintenance_501813-1145.jpg?w=826'),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BatteryIndicator()),
                  );
                },
              ),
              height: 240,
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 19, 206, 94).withOpacity(0.6),
              ),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Battery Management',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      );

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Feedback Form'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40.0,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  Text(
                    'Rating: $_rating',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Tell us how we can improve more'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save the feedback to Firebase
                    _saveFeedback();
                    Navigator.of(context).pop();
                    // Close the app after submitting feedback
                    SystemNavigator.pop();
                  },
                  child: Text('Submit Feedback'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveFeedback() {
    final feedback = {
      'rating': _rating.toDouble(),
      'comment': _controller.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance.collection('feedback').add(feedback);
    // Replace 'feedback' with the desired collection name in Firestore
    // Make sure you've initialized Firebase in your app
  }
}
