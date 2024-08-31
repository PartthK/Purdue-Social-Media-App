import 'dart:async';  // Import Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

      if (_isEmailVerified || _retryCount >= 12) {  // Stop after 60 seconds (12*5 seconds)
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
        title: Text(
          'Select the topics of your interest',
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest);

                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          interest,
                          style: GoogleFonts.montserrat(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
