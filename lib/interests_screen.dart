import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart'; // Import HomeScreen

class InterestsScreen extends StatelessWidget {
  final List<String> _interests = [
    'Tech', 'AI/ML', 'Music', 'Biology', 'Physics', 'Chemistry', 'Sports', 'Art',
    'Literature', 'Dance', 'Theatre', 'Film', 'Photography', 'Travel', 'Cooking',
    'Fashion', 'Finance', 'Entrepreneurship', 'Gaming', 'Fitness'
  ];

  final Set<String> _selectedInterests = {};
  final String name;

  InterestsScreen({required this.name});

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
                      (context as Element).markNeedsBuild();
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
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final user = authProvider.user;

                if (user != null && user.email != null) {
                  // Save interests to Firestore
                  await _saveInterests(user.email!, name);

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
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              ),
              child: Text(
                'Save and Continue',
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
      'rsvpEvents': [],
    });
  }
}
