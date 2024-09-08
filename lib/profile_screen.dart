// File: profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'event_detail_screen.dart';
import 'event_model.dart';
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
  List<String> userInterests = [];
  List<String> userFriends = [];
  List<Map<String, dynamic>> userEvents = [];
  String? bio = '';
  List<String> _allTags = ['Tech', 'AI/ML', 'Music', 'Biology', 'Physics', 'Sports', 'Art'];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _checkFriendshipStatus();
    _fetchEventCount();
    _fetchFriendCount();
    _fetchUserInterests();
    _fetchUserFriends();
    _fetchUserEvents();
    _fetchBio();
  }

  /// Fetches user interests (tags) from Firestore.
  void _fetchUserInterests() async {
    try {
      final currentUserDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> interests = List<String>.from(currentUserDoc['tags'] ?? []);
      setState(() {
        userInterests = interests;
        selectedTags = interests;
      });
    } catch (e) {
      print('Error fetching user interests: $e');
    }
  }

  /// Fetches user friends from Firestore.
  void _fetchUserFriends() async {
    try {
      final currentUserDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> friends = List<String>.from(currentUserDoc['friends'] ?? []);
      setState(() {
        userFriends = friends;
      });
    } catch (e) {
      print('Error fetching user friends: $e');
    }
  }

  /// Fetches user events from Firestore.
  void _fetchUserEvents() async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('username', isEqualTo: widget.userId)
          .get();

      setState(() {
        userEvents = eventSnapshot.docs
            .map((doc) => {'documentId': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      print('Error fetching user events: $e');
    }
  }

  /// Fetches the count of user friends.
  void _fetchFriendCount() async {
    try {
      final currentUserDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> friends = List<String>.from(currentUserDoc['friends'] ?? []);

      setState(() {
        friendCount = friends.length;
      });
    } catch (e) {
      print('Error fetching friend count: $e');
    }
  }

  /// Fetches the count of user events.
  void _fetchEventCount() async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('username', isEqualTo: widget.userId)
          .get();

      setState(() {
        eventCount = eventSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching event count: $e');
    }
  }

  /// Fetches the user's bio from Firestore.
  void _fetchBio() async {
    try {
      final currentUserDoc =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      String userBio = currentUserDoc['bio'] ?? '';
      setState(() {
        bio = userBio;
      });
    } catch (e) {
      print('Error fetching bio: $e');
    }
  }

  /// Checks the friendship status between the current user and the profile user.
  void _checkFriendshipStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final currentUserDoc =
        await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();
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
      } catch (e) {
        print('Error checking friendship status: $e');
      }
    }
  }

  /// Builds the profile screen UI.
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: currentUser?.email == widget.userId
          ? null // Hide the AppBar if it's the current user's profile
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
                  MaterialPageRoute(builder: (context) => HomeScreen()),
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
          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching profile details',
                style: GoogleFonts.montserrat(fontSize: 24.0, color: Colors.white),
              ),
            );
          }

          // Handle case when profile does not exist
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found',
                style: GoogleFonts.montserrat(fontSize: 24.0, color: Colors.white),
              ),
            );
          }

          // Extract user data
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'N/A';
          _profileImageUrl = data['profileImageUrl'] ?? null;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header with background gradient and avatar
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
                          // Profile Image
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
                          // User Name
                          Text(
                            name,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // User Bio
                          if (bio != null && bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                bio!,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                // Counters for Events and Friends
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: _showEventsDialog, // Show events pop-up
                        child: _buildCounter('Events', eventCount),
                      ),
                      GestureDetector(
                        onTap: _showFriendsDialog, // Show friends pop-up
                        child: _buildCounter('Friends', friendCount),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit Profile Button (only visible to the profile owner)
                      if (currentUser?.email == widget.userId)
                        Expanded(
                          child: _buildProfileButton('Edit Profile', _showEditProfileDialog),
                        ),
                      if (currentUser?.email == widget.userId)
                        SizedBox(width: 10), // Spacing between buttons
                      // Interests Button
                      Expanded(
                        child: _buildProfileButton('Interests', _showInterestsDialog),
                      ),
                      // Send Friend Request Button (only visible to other users)
                      if (currentUser?.email != widget.userId)
                        SizedBox(width: 10), // Spacing between buttons
                      if (currentUser?.email != widget.userId)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: buttonText == 'Send Friend Request' ||
                                buttonText == 'Sent Request'
                                ? () async {
                              await sendFriendRequest(widget.userId);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonText == 'Sent Request'
                                  ? Colors.grey
                                  : Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 16.0),
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
                // Placeholder for Events (if no events)
                if (userEvents.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white38, size: 100),
                        Text(
                          'No Events Posted Yet',
                          style: GoogleFonts.montserrat(
                            color: Colors.white38,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                // List of User Events
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      final event = userEvents[index];
                      return ListTile(
                        leading: Icon(Icons.event, color: Colors.orangeAccent),
                        title: Text(
                          event['title'] ?? 'No Title',
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontSize: 18.0),
                        ),
                        subtitle: Text(
                          event['description'] ?? 'No Description',
                          style: GoogleFonts.montserrat(
                              color: Colors.white70, fontSize: 14.0),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                event: Event.fromJson(event['documentId'], event),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a counter widget for Events and Friends.
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

  /// Builds a profile action button.
  Widget _buildProfileButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding:
        EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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

  /// Handles profile image picking and uploading.
  Future<void> _pickImage() async {
    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
    }
  }

  /// Sends a friend request to another user.
  Future<void> sendFriendRequest(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .get();

        List<String> currentUserFriends =
        List<String>.from(currentUserDoc['friends'] ?? []);
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

        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friendRequests')
            .add({
          'from': currentUser.email,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          buttonText = 'Sent Request';
        });

        // Send push notification (requires additional setup)
        // Uncomment and configure the following lines if Firebase Messaging is set up
        /*
        await FirebaseMessaging.instance.sendMessage(
          to: friendId, // This should be the FCM token of the friend
          data: {
            'title': 'Friend Request',
            'body': '${currentUser.email} sent you a friend request',
          },
        );
        */

        print('Friend request sent.');
      } catch (e) {
        print('Error sending friend request: $e');
      }
    }
  }

  /// Displays a dialog with the user's interests.
  void _showInterestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
        Text('Interests', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: userInterests.isNotEmpty
            ? Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: userInterests
              .map((interest) => Chip(
            label: Text(interest),
            backgroundColor: Colors.orangeAccent,
            labelStyle: GoogleFonts.montserrat(color: Colors.white),
          ))
              .toList(),
        )
            : Text(
          'No interests available',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Displays a dialog with the user's friends.
  void _showFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
        Text('Friends', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: userFriends.isNotEmpty
            ? Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userFriends.length,
            itemBuilder: (context, index) {
              final friendId = userFriends[index];
              return ListTile(
                leading: Icon(Icons.person, color: Colors.orangeAccent),
                title: Text(
                  friendId,
                  style: GoogleFonts.montserrat(),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: friendId),
                    ),
                  );
                },
              );
            },
          ),
        )
            : Text(
          'No friends available',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Displays a dialog with the user's events.
  void _showEventsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
        Text('Events', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: userEvents.isNotEmpty
            ? Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userEvents.length,
            itemBuilder: (context, index) {
              final event = userEvents[index];
              return ListTile(
                leading: Icon(Icons.event, color: Colors.orangeAccent),
                title: Text(
                  event['title'] ?? 'No Title',
                  style: GoogleFonts.montserrat(),
                ),
                subtitle: Text(
                  event['description'] ?? 'No Description',
                  style: GoogleFonts.montserrat(),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(
                        event: Event.fromJson(event['documentId'], event),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
            : Text(
          'No events available',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Displays a dialog to edit the user's profile.
  void _showEditProfileDialog() {
    final TextEditingController nameController =
    TextEditingController(text: '');
    final TextEditingController bioController =
    TextEditingController(text: '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
        Text('Edit Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Bio Input
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              // Interests Selection
              MultiSelectDialogField(
                items: _allTags
                    .map((tag) => MultiSelectItem<String>(tag, tag))
                    .toList(),
                initialValue: selectedTags,
                onConfirm: (values) {
                  setState(() {
                    selectedTags = List<String>.from(values);
                  });
                },
                buttonText: Text('Select Interests'),
                title: Text('Interests'),
                selectedColor: Colors.orangeAccent,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                searchable: true,
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            child: Text('Cancel', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // Save Button
          TextButton(
            child: Text('Save', style: GoogleFonts.montserrat()),
            onPressed: () async {
              final newName = nameController.text.trim();
              final newBio = bioController.text.trim();

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name cannot be empty')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .update({
                  'name': newName,
                  'bio': newBio,
                  'tags': selectedTags,
                });

                setState(() {
                  // Update local state if necessary
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                print('Error updating profile: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update profile')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
