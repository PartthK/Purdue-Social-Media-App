import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e);
    }
  }
  //Chota change
  Future<void> signup(String name, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.sendEmailVerification();
      await _auth.currentUser?.updateDisplayName(name);
      await _firestore.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'profilePictureUrl': "",
        'tags': [],
        'rsvpEvents': []

      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }
}
