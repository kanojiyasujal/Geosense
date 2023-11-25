import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WhitelistContactsPage(),
    );
  }
}

class WhitelistContactsPage extends StatefulWidget {
  @override
  _WhitelistContactsPageState createState() => _WhitelistContactsPageState();
}

class _WhitelistContactsPageState extends State<WhitelistContactsPage> {
  List<Contact> _commonContacts = [];

  @override
  void initState() {
    super.initState();
    _getCommonContacts();
  }

  Future<void> _getCommonContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> userContacts = await ContactsService.getContacts();

      // Fetch phone numbers from Firestore
      QuerySnapshot<Map<String, dynamic>> firebaseData =
          await FirebaseFirestore.instance.collection('users').get();
      List<String?> phoneNumbersFromFirestore = firebaseData.docs
          .map((doc) => doc.get('phoneNumber') as String?)
          .where((phoneNumber) => phoneNumber != null)
          .toList();

      // Find common contacts based on phone numbers
      List<Contact> commonContacts = userContacts
          .where((userContact) =>
              userContact.phones != null &&
              userContact.phones!.isNotEmpty &&
              phoneNumbersFromFirestore.contains(userContact.phones!.first.value))
          .toList();

      setState(() {
        _commonContacts = commonContacts;
      });
    } else {
      // Handle case when permission is not granted
      _showPermissionDialog();
      print('Permission not granted');
    }
  }

  Future<void> _showPermissionDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('Please grant permission to access contacts in settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Common Contacts'),
      ),
      body: (_commonContacts.isNotEmpty)
          ? ListView.builder(
              itemCount: _commonContacts.length,
              itemBuilder: (context, index) {
                Contact contact = _commonContacts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: (contact.avatar != null && contact.avatar!.length > 0)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar!),
                            )
                          : Icon(Icons.person),
                      title: Text(contact.displayName ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (contact.phones != null && contact.phones!.isNotEmpty)
                            Text('Phone: ${contact.phones!.first.value}'),
                          if (contact.emails != null && contact.emails!.isNotEmpty)
                            Text('Email: ${contact.emails!.first.value}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No common contacts available'),
            ),
    );
  }
}
