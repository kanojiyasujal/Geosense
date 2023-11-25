


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'location_detail.dart';




class LocationListPage extends StatefulWidget {
  const LocationListPage({Key? key}) : super(key: key);

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location List'),
      ),
      body: Stack(
  children: [
    Image.asset(
      'assets/images/location-tracking-concept-illustration_114360-5155-removebg-preview.png', // Replace with the actual path to your PNG image
      fit: BoxFit.contain, // You can adjust the fit as needed
      width: double.infinity,
      height: double.infinity,
    ),
    _buildLocationList(),
  ],
));
  }

  Widget _buildLocationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(), // Loading indicator centered
          );
        }

        final locations = snapshot.data!.docs;

        if (locations.isEmpty) {
          return Center(
            child: Text('No locations found.'),
          );
        }

        return Scrollbar(
          child: ListView.separated(
            itemCount: locations.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final locationData = locations[index].data() as Map<String, dynamic>;
              final name = locationData['name'] ?? 'No Name';
              final address = locationData['address'] ?? 'No Address';
              final lat = locationData['lat'] as double?;
              final lng = locationData['lng'] as double?;

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    address,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    // Navigate to the LocationDetailPage and pass location details
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LocationDetailPage(
                          name: name,
                          address: address,
                          lat: lat,
                          lng: lng,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDeleteConfirmationDialog(
                      context,
                      locations[index].reference,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentReference locationReference) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Location'),
          content: Text('Are you sure you want to delete this location?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                 // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteLocation(locationReference);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLocation(DocumentReference reference) {
    reference.delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location deleted successfully.'),
        ),
        
      );
    }).catchError((error) {
      print('Error deleting location: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete location.'),
        ),
      );
    });
  }
  
}


