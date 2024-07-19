import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No user logged in',
            style: GoogleFonts.montserrat(fontSize: 24.0),
          ),
        ),
      );
    }

    final email = authProvider.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Color(0xfff3f1f7),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(email).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching profile details',
                style: GoogleFonts.montserrat(fontSize: 24.0),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found',
                style: GoogleFonts.montserrat(fontSize: 24.0),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'N/A';
          final tags = List<String>.from(data['tags'] ?? []);

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email: $email',
                  style: GoogleFonts.montserrat(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Interests:',
                  style: GoogleFonts.montserrat(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                ...tags.map((tag) => Text(
                  tag,
                  style: GoogleFonts.montserrat(fontSize: 18.0),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
