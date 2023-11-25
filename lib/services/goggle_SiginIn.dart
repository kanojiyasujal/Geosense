
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/home/components/home_screen.dart';




class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Authentication successful, you can now navigate to the home screen.
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage(title: 'Home Screen',)));
        return true;
      } else {
        // Authentication failed.
        return false;
      }
    } catch (error) {
      // Handle any errors that occur during the sign-in process.
      print(error.toString());
      return false;
    }
  }
}

