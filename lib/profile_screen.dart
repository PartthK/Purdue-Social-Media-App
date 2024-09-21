import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'event_detail_screen.dart';
import 'event_model.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool isDarkMode = false;
  String? _profileImageUrl;
  String buttonText = 'Send Friend Request';
  int eventCount = 0;
  int friendCount = 0;
  List<String> userInterests = [];
  List<String> userFriends = [];
  List<Map<String, dynamic>> userEvents = [];
  String? bio = '';
  String? name = '';
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
    _fetchProfileInfo();
  }

  void _fetchProfileInfo() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      setState(() {
        name = currentUserDoc['name'] ?? '';
        bio = currentUserDoc['bio'] ?? '';
        selectedTags = List<String>.from(currentUserDoc['tags'] ?? []);
        _profileImageUrl = currentUserDoc['profileImageUrl'];
      });
    } catch (e) {
      print('Error fetching profile info: $e');
    }
  }

  void _fetchUserInterests() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> interests = List<String>.from(currentUserDoc['tags'] ?? []);
      setState(() {
        userInterests = interests;
        selectedTags = interests;
      });
    } catch (e) {
      print('Error fetching user interests: $e');
    }
  }

  void _fetchUserFriends() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> friends = List<String>.from(currentUserDoc['friends'] ?? []);
      setState(() {
        userFriends = friends;
      });
    } catch (e) {
      print('Error fetching user friends: $e');
    }
  }

  void _fetchUserEvents() async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('username', isEqualTo: widget.userId)
          .get();

      setState(() {
        userEvents = eventSnapshot.docs.map((doc) => {
          'documentId': doc.id,
          ...doc.data() as Map<String, dynamic>
        }).toList();
      });
    } catch (e) {
      print('Error fetching user events: $e');
    }
  }

  void _refreshEvents() {
    try {
      _fetchUserEvents();
      setState(() {});
    } catch (e) {
      print('Error refreshing events: $e');
    }
  }

  Future<void> _createEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'username': widget.userId,
        'title': 'New Event',
        'description': 'Event Description',
      });
      _refreshEvents();
    } catch (e) {
      print('Error creating event: $e');
    }
  }

  void _fetchFriendCount() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      List<String> friends = List<String>.from(currentUserDoc['friends'] ?? []);

      setState(() {
        friendCount = friends.length;
      });
    } catch (e) {
      print('Error fetching friend count: $e');
    }
  }

  void _fetchEventCount() async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').where('username', isEqualTo: widget.userId).get();

      setState(() {
        eventCount = eventSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching event count: $e');
    }
  }

  void _checkFriendshipStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
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
      } catch (e) {
        print('Error checking friendship status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                style: GoogleFonts.montserrat(fontSize: 24.0, color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found',
                style: GoogleFonts.montserrat(fontSize: 24.0, color: isDarkMode ? Colors.white : Colors.black),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userName = data['name'] ?? 'N/A';
          _profileImageUrl = data['profileImageUrl'] ?? null;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 250.0,
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
                            userName,
                            style: GoogleFonts.montserrat(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (bio != null && bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                bio!,
                                style: GoogleFonts.montserrat(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: _showEventsDialog,
                        child: _buildCounter('Events', eventCount, isDarkMode),
                      ),
                      GestureDetector(
                        onTap: _showFriendsDialog,
                        child: _buildCounter('Friends', friendCount, isDarkMode),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (FirebaseAuth.instance.currentUser?.email == widget.userId)
                        Expanded(
                          child: _buildProfileButton('Edit Profile', _showEditProfileDialog, isDarkMode),
                        ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildProfileButton('Interests', _showInterestsDialog, isDarkMode),
                      ),
                      if (FirebaseAuth.instance.currentUser?.email != widget.userId)
                        SizedBox(width: 10),
                      if (FirebaseAuth.instance.currentUser?.email != widget.userId)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: buttonText == 'Send Friend Request' || buttonText == 'Sent Request'
                                ? () async {
                              await sendFriendRequest(widget.userId);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonText == 'Already Friends'
                                  ? Colors.red
                                  : (buttonText == 'Sent Request' ? Colors.grey : Colors.orangeAccent),
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
                Divider(color: isDarkMode ? Colors.white38 : Colors.black38),
                if (userEvents.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, color: isDarkMode ? Colors.white38 : Colors.black38, size: 100),
                        Text(
                          'No Events Posted Yet',
                          style: GoogleFonts.montserrat(
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
                          style: GoogleFonts.montserrat(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18.0),
                        ),
                        subtitle: Text(
                          event['description'] ?? 'No Description',
                          style: GoogleFonts.montserrat(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 14.0),
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

  Widget _buildCounter(String label, int count, bool isDarkMode) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.montserrat(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(String text, VoidCallback onPressed, bool isDarkMode) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
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
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
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
    } catch (e) {
      print('Error picking/uploading image: $e');
    }
  }

  Future<void> sendFriendRequest(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.email).get();

        List<String> currentUserFriends = List<String>.from(currentUserDoc['friends'] ?? []);
        if (currentUserFriends.contains(friendId)) {
          setState(() {
            buttonText = 'Friends';
          });
          return;
        }

        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(friendId).collection('friendRequests').where('from', isEqualTo: currentUser.email).where('status', isEqualTo: 'pending').get();

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

        print('Friend request sent.');
      } catch (e) {
        print('Error sending friend request: $e');
      }
    }
  }

  void _showInterestsDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text('Interests', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        content: userInterests.isNotEmpty
            ? Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: userInterests.map((interest) => Chip(
            label: Text(interest),
            backgroundColor: Colors.orangeAccent,
            labelStyle: GoogleFonts.montserrat(color: Colors.white),
          )).toList(),
        )
            : Text('No interests available', style: GoogleFonts.montserrat(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.montserrat(color: isDarkMode ? Colors.white : Colors.black)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Friends', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
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
                title: Text(friendId, style: GoogleFonts.montserrat()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(userId: friendId)),
                  );
                },
              );
            },
          ),
        )
            : Text('No friends available', style: GoogleFonts.montserrat()),
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

  void _showEventsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Events', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
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
                title: Text(event['title'] ?? 'No Title', style: GoogleFonts.montserrat()),
                subtitle: Text(event['description'] ?? 'No Description', style: GoogleFonts.montserrat()),
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
        )
            : Text('No events available', style: GoogleFonts.montserrat()),
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

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController bioController = TextEditingController(text: bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              MultiSelectDialogField(
                items: _allTags.map((tag) => MultiSelectItem<String>(tag, tag)).toList(),
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
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                searchable: true,
                itemsTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                selectedItemsTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.montserrat()),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Save', style: GoogleFonts.montserrat()),
            onPressed: () async {
              final newName = nameController.text.trim();
              final newBio = bioController.text.trim();

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Name cannot be empty')));
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                  'name': newName,
                  'bio': newBio,
                  'tags': selectedTags,
                });

                setState(() {
                  name = newName;
                  bio = newBio;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
              } catch (e) {
                print('Error updating profile: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
              }
            },
          ),
        ],
      ),
    );
  }
}
