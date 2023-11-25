import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedMessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Messages'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('battery_data').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var messages = snapshot.data!.docs;

          List<GestureDetector> messageCards = [];
          for (var message in messages) {
            var messageData = message.data() as Map<String, dynamic>;
            var threshold = messageData['batteryThreshold'];
            var customMessage = messageData['customMessage'];

            var messageCard = GestureDetector(
              onLongPress: () {
                // Show a dialog to confirm deletion
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Message'),
                      content: Text('Are you sure you want to delete this message?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Delete the message from Firestore
                            FirebaseFirestore.instance.collection('battery_data').doc(message.id).delete();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Threshold: $threshold%',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Message: $customMessage',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );

            messageCards.add(messageCard);
          }

          return ListView(
            children: messageCards,
          );
        },
      ),
    );
  }
}
