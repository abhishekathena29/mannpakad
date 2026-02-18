import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuthProvider extends ChangeNotifier {
  String error = "";
  loginWithGoogle() {
    try {} catch (e) {
      error = e.toString();
    }
  }

  loginWithEmail(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // save these data to firestore
      }
    } on Exception catch (e) {
      error = e.toString();
    }
  }

  signupWithEmail(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        // save these data to firestore
      }
    } catch (e) {}
  }

  sigout() {}
}
