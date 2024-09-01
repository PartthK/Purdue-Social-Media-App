import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl;
  String buttonText = 'Send Friend Request'; // Default button text
  Map<String, String> friendNames = {}; // Store friend emails and their corresponding names

  @override
  void initState() {
    super.initState();
    _checkFriendshipStatus();
    _fetchFriendNames(); // Fetch the names of the friends
  }

  void _fetchFriendNames() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();
      List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);

      // Fetch each friend's name
      for (String friendEmail in currentUserFriends) {
        DocumentSnapshot friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendEmail).get();
        String friendName = friendDoc['name'] ?? friendEmail; // Use email if name is not available

        setState(() {
          friendNames[friendEmail] = friendName; // Store friend's name using email as key
        });
      }
    }
  }

  void _checkFriendshipStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      // Check if they are already friends
      List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);
      if (currentUserFriends.contains(widget.userId)) {
        setState(() {
          buttonText = 'Friends';
        });
        return;
      }

      // Check if a friend request has already been sent
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
          final friends = List<String>.from(data['friends'] ?? []);
          _profileImageUrl = data['profileImageUrl'] ?? null;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 16.0),
                Text(
                  'Email: ${widget.userId}',
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
                Text(
                  'Friends:',
                  style: GoogleFonts.montserrat(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                ...friends.map((friendEmail) => FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(friendEmail).get(),
                  builder: (context, friendSnapshot) {
                    if (friendSnapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        friendEmail,
                        style: GoogleFonts.montserrat(fontSize: 18.0),
                      );
                    }

                    if (friendSnapshot.hasError || !friendSnapshot.hasData || !friendSnapshot.data!.exists) {
                      return Text(
                        friendEmail,
                        style: GoogleFonts.montserrat(fontSize: 18.0),
                      );
                    }

                    final friendData = friendSnapshot.data!.data() as Map<String, dynamic>;
                    final friendName = friendData['name'] ?? friendEmail;

                    return Text(
                      '$friendName ($friendEmail)',
                      style: GoogleFonts.montserrat(fontSize: 18.0),
                    );
                  },
                )),
                SizedBox(height: 16.0),
                if (currentUser?.email != widget.userId)
                  ElevatedButton(
                    onPressed: buttonText == 'Send Friend Request' ? () async {
                      await sendFriendRequest(widget.userId);
                    } : null,
                    child: Text(buttonText),
                  ),
              ],
            ),
          );
        },
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

      // Update Firestore with the new profile image URL
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
      final friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();

      // Check if the current user is already friends with the target user
      List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);
      if (currentUserFriends.contains(friendId)) {
        setState(() {
          buttonText = 'Friends';
        });
        return; // Exit the function if they are already friends
      }

      // Check if there's already a pending friend request
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friendRequests')
          .where('from', isEqualTo: currentUser.email)
          .where('status', isEqualTo: 'pending') // Assuming you have a status field
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          buttonText = 'Sent Request';
        });
        return;
      }

      // Otherwise, send a new friend request
      await FirebaseFirestore.instance.collection('users').doc(friendId).collection('friendRequests').add({
        'from': currentUser.email,
        'status': 'pending', // Add status field
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        buttonText = 'Sent Request';
      });

      // Send notification
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
  //hello
}