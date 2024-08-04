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
  String _friendRequestStatus = 'Send Friend Request';
  List<String> _friends = [];

  @override
  void initState() {
    super.initState();
    _checkFriendRequestStatus();
    _fetchFriends();
  }

  Future<void> _checkFriendRequestStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final sentRequestSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('friendRequests')
        .where('from', isEqualTo: currentUser.email)
        .get();

    final receivedRequestSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('friendRequests')
        .where('from', isEqualTo: widget.userId)
        .get();

    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .collection('friends')
        .doc(widget.userId)
        .get();

    setState(() {
      if (friendsSnapshot.exists) {
        _friendRequestStatus = 'Friends';
      } else if (receivedRequestSnapshot.docs.isNotEmpty) {
        _friendRequestStatus = 'Accept Friend Request';
      } else if (sentRequestSnapshot.docs.isNotEmpty) {
        _friendRequestStatus = 'Request Sent';
      } else {
        _friendRequestStatus = 'Send Friend Request';
      }
    });
  }

  Future<void> _fetchFriends() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('friends')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _friends = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

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

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'N/A';
          final tags = List<String>.from(data?['tags'] ?? []);
          _profileImageUrl = data?['profileImageUrl'] ?? null;

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
                SizedBox(height: 16.0),
                if (currentUser?.email != widget.userId && _friendRequestStatus != 'Friends')
                  ElevatedButton(
                    onPressed: _friendRequestStatus == 'Send Friend Request'
                        ? () => sendFriendRequest(widget.userId)
                        : null,
                    child: Text(_friendRequestStatus),
                  ),
                SizedBox(height: 16.0),
                Text(
                  'Friends:',
                  style: GoogleFonts.montserrat(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                _friends.isEmpty
                    ? Text(
                  'No friends to display',
                  style: GoogleFonts.montserrat(fontSize: 18.0),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(_friends[index]).get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Container();
                          }

                          final friendData = snapshot.data!.data() as Map<String, dynamic>?;
                          final friendName = friendData?['name'] ?? 'Unknown';
                          final friendEmail = friendData?['email'] ?? 'Unknown';

                          return ListTile(
                            title: Text(friendName),
                            subtitle: Text(friendEmail),
                          );
                        },
                      );
                    },
                  ),
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
      await FirebaseFirestore.instance.collection('users').doc(friendId).collection('friendRequests').add({
        'from': currentUser.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _friendRequestStatus = 'Request Sent';
      });

      // Send notification
      FirebaseMessaging.instance.sendMessage(
        to: friendId,
        data: {
          'title': 'Friend Request',
          'body': '${currentUser.email} sent you a friend request.',
        },
      );
    }
  }
}