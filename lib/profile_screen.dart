import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:purdue_social/search_screen.dart';

import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  String buttonText = 'Send Friend Request';
  int eventCount = 0;
  int friendCount = 0;

  @override
  void initState() {
    super.initState();
    _checkFriendshipStatus();
    _fetchEventCount();
    _fetchFriendCount();
  }

  void _fetchFriendCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> friends = List<String>.from(currentUserDoc['friends'] ?? []);

      setState(() {
        friendCount = friends.length;
      });
    }
  }

  void _fetchEventCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.userId)
          .get();

      setState(() {
        eventCount = eventSnapshot.docs.length;
      });
    }
  }

  void _checkFriendshipStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();

      List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);
      if (currentUserFriends.contains(widget.userId)) {
        setState(() {
          buttonText = 'Already Friends';
        });
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('friendRequests')
          .where('from', isEqualTo: currentUser.email)
          .where('status', isEqualTo: 'pending')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          buttonText = 'Sent Request';
        });
      } else {
        setState(() {
          buttonText = 'Send Friend Request';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: currentUser?.email == widget.userId
          ? null  // Hide the AppBar if it's the current user's profile
          : PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text('Profile', style: GoogleFonts.montserrat()),
            backgroundColor: Colors.transparent, // Make the AppBar background transparent
            elevation: 0, // Remove AppBar shadow
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Ensure HomeScreen is imported
                );
              },
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF0D1114),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching profile details',
                style: GoogleFonts.montserrat(fontSize: 24.0, color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found',
                style: GoogleFonts.montserrat(fontSize: 24.0, color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'N/A';
          _profileImageUrl = data['profileImageUrl'] ?? null;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orangeAccent, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 35.0,
                      left: 20.0,
                      right: 20.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : AssetImage('assets/default_avatar.png') as ImageProvider,
                              child: _profileImageUrl == null
                                  ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            name,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCounter('Events', eventCount),
                      _buildCounter('Friends', friendCount),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (currentUser?.email == widget.userId)
                        Expanded(
                          child: _buildProfileButton('Edit Profile', () {
                            // Handle Edit Profile action
                          }),
                        ),
                      if (currentUser?.email == widget.userId)
                        SizedBox(width: 10),  // Add spacing between buttons
                      Expanded(
                        child: _buildProfileButton('Interests', () {
                          // Handle Interests action
                        }),
                      ),
                      if (currentUser?.email != widget.userId) // Only show if not own profile
                        SizedBox(width: 10),  // Add spacing between buttons
                      if (currentUser?.email != widget.userId)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: buttonText == 'Send Friend Request' || buttonText == 'Sent Request'
                                ? () async {
                              await sendFriendRequest(widget.userId);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonText == 'Sent Request' ? Colors.grey : Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            ),
                            child: Text(
                              buttonText,
                              style: GoogleFonts.montserrat(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(color: Colors.white38),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 100),
                      Text(
                        'No Events Posted Yet',
                        style: GoogleFonts.montserrat(
                          color: Colors.white38,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCounter(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profileImageUrl': downloadUrl,
      });

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    }
  }

  Future<void> sendFriendRequest(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();

      List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);
      if (currentUserFriends.contains(friendId)) {
        setState(() {
          buttonText = 'Friends';
        });
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friendRequests')
          .where('from', isEqualTo: currentUser.email)
          .where('status', isEqualTo: 'pending')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          buttonText = 'Sent Request';
        });
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(friendId).collection('friendRequests').add({
        'from': currentUser.email,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        buttonText = 'Sent Request';
      });

      FirebaseMessaging.instance.sendMessage(
        to: friendId,
        data: {
          'title': 'Friend Request',
          'body': '${currentUser.email} sent you a friend request',
        },
      );

      print('Friend request sent.');
    }
  }
}
// hello