import 'dart:async';  // Import Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purdue_social/signup_screen.dart';
import 'auth_provider.dart' as my_auth_provider;  // Aliased import
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth

class InterestsScreen extends StatefulWidget {
  final String name;

  InterestsScreen({required this.name});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<String> _interests = [
    'Tech', 'AI/ML', 'Music', 'Biology', 'Physics', 'Chemistry', 'Sports', 'Art',
    'Literature', 'Dance', 'Theatre', 'Film', 'Photography', 'Travel', 'Cooking',
    'Fashion', 'Finance', 'Entrepreneurship', 'Gaming', 'Fitness'
  ];

  final Set<String> _selectedInterests = {};
  bool _isEmailVerified = false;  // Track email verification status
  bool _isLoading = false;        // Track loading state
  Timer? _timer;                  // Timer to poll for email verification
  int _retryCount = 0;            // Counter for the number of retries

  @override
  void initState() {
    super.initState();
    _startEmailVerificationPolling();  // Start polling for email verification
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startEmailVerificationPolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      _retryCount += 1;
      await _checkEmailVerification();

      if (_isEmailVerified) {  // Stop after 60 seconds (12*5 seconds)
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;  // Show loading indicator while checking
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();  // Reload user to get the latest status
      setState(() {
        _isEmailVerified = user.emailVerified;  // Update verification status
        _isLoading = false;  // Hide loading indicator
      });

      if (_isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email verified! You can now continue.')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Interests'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select your interests',
              style: GoogleFonts.montserrat(
                fontSize: 24.0, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _interests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return ChoiceChip(
                    label: Text(
                      interest,
                      style: GoogleFonts.montserrat(
                        fontSize: 18.0,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isEmailVerified
                  ? () async {
                final authProvider = Provider.of<my_auth_provider.AuthProvider>(context, listen: false);
                final user = authProvider.user;

                if (user != null && user.email != null) {
                  // Save interests to Firestore
                  await _saveInterests(user.email!, widget.name);

                  // Redirect to home screen after saving interests
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No user logged in or email is null')),
                  );
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isEmailVerified ? Colors.black : Colors.grey, // Grey out the button if not verified
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                _isEmailVerified ? 'Save and Continue' : 'Please Verify Email',
                style: GoogleFonts.montserrat(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInterests(String email, String name) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(email).set({
      'name': name,
      'email': email,
      'tags': _selectedInterests.toList(),
      'friends': [],
      'rsvpEvents': [],
    });
  }
}
