import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';
import 'auth_provider.dart' as custom_auth;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isDarkMode = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _allTags = [
    'Tech', 'AI/ML', 'Music', 'Biology', 'Physics', 'Chemistry', 'Sports', 'Art',
    'Literature', 'Dance', 'Theatre', 'Film', 'Photography', 'Travel', 'Cooking',
    'Fashion', 'Finance', 'Entrepreneurship', 'Gaming', 'Fitness'
  ];
  List<String> _selectedTags = [];
  File? _image;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDarkMode = themeData.brightness == Brightness.dark;
    final User? user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'BoilerVibe',
            style: GoogleFonts.outfit(
              color: Colors.orange,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Iconsax.menu_14,
              size: 30.0,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.setting_24),
            onPressed: () => _showProfileOptions(context, userEmail),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 0.2,
          ),
        ),
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                    ),
                    margin: EdgeInsets.only(bottom: 0),
                    padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'BoilerVibe',
                            style: GoogleFonts.outfit(
                              color: Colors.orange,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, bottom: 0),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Consumer<custom_auth.AuthProvider>(
                              builder: (context, authProvider, _) {
                                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                return FloatingActionButton(
                                  onPressed: () {
                                    print("FloatingActionButton pressed");
                                    authProvider.toggleThemeMode();
                                  },
                                  child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                                  mini: true,
                                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDrawerItem(
                      Iconsax.home,
                      'Home',
                      0,
                      Theme.of(context).primaryColor,
                      Colors.grey,
                      Theme.of(context).brightness == Brightness.dark
                  ),
                  _buildDrawerItem(
                      Iconsax.search_normal,
                      'Search',
                      1,
                      Theme.of(context).primaryColor,
                      Colors.grey,
                      Theme.of(context).brightness == Brightness.dark
                  ),
                  _buildDrawerItem(
                      Iconsax.notification,
                      'Notifications',
                      2,
                      Theme.of(context).primaryColor,
                      Colors.grey,
                      Theme.of(context).brightness == Brightness.dark
                  ),
                  _buildDrawerItem(
                      Iconsax.user,
                      'Profile',
                      3,
                      Theme.of(context).primaryColor,
                      Colors.grey,
                      Theme.of(context).brightness == Brightness.dark
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Iconsax.shield_tick, color: Theme.of(context).primaryColor),
                    title: Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _launchURL('https://boilervibe.framer.website/'),
                  ),
                  ListTile(
                    leading: Icon(Iconsax.document, color: Theme.of(context).primaryColor),
                    title: Text(
                      'Terms of Use',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _launchURL('https://boilervibe.framer.website/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventScreen(),
          SearchScreen(),
          if (userEmail.isNotEmpty) NotificationsScreen(userId: userEmail),
          if (userEmail.isNotEmpty) ProfileScreen(userId: userEmail),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () => _showAddEventModal(context),
        child: Icon(
          Icons.add,
          color: Theme.of(context).hintColor,
        ),
        backgroundColor: themeData.primaryColor,
      ) : null,
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
          items: [
            SalomonBottomBarItem(
              icon: Icon(Iconsax.home, size: 24.0, color: Theme.of(context).primaryColor),
              title: Text(
                'Home',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              selectedColor: Colors.grey,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.search_normal, size: 24.0, color: Theme.of(context).primaryColor),
              title: Text(
                'Search',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              selectedColor: Colors.grey,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.notification, size: 24.0, color: Theme.of(context).primaryColor),
              title: Text(
                'Notifications',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              selectedColor: Colors.grey,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.user, size: 24.0, color: Theme.of(context).primaryColor),
              title: Text(
                'Profile',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              selectedColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, int index, Color selectedColor, Color unselectedColor, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? selectedColor : unselectedColor,
      ),
      title: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16.0,
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          color: _selectedIndex == index ? selectedColor : unselectedColor,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
          Navigator.pop(context);
        });
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showAddEventModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Event',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Time: ${_selectedTime.format(context)}',
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Tags:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  MultiSelectDialogField(
                    items: _allTags.map((tag) => MultiSelectItem<String>(tag, tag)).toList(),
                    initialValue: _selectedTags,
                    onConfirm: (values) {
                      setState(() {
                        _selectedTags = List<String>.from(values);
                      });
                    },
                    buttonText: Text('Select Tags'),
                    title: Text('Tags'),
                    selectedColor: Colors.black,
                    unselectedColor: Colors.black.withOpacity(0.5),
                    searchable: true,
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: _image == null
                            ? Text('No image selected')
                            : Image.file(_image!),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      final imageUrl = await _uploadImage();
                      _addEvent(imageUrl);
                      Navigator.pop(context); // Close the modal
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
                      'Save Event',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('event_images').child(DateTime.now().toIso8601String());
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _addEvent(String? imageUrl) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    final userName = user?.displayName ?? '';
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    await events.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'createdBy': userName,
      'username': userEmail,
      'date': Timestamp.fromDate(
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      ),
      'rsvpCount': 0,
      'tags': _selectedTags,
      'image': imageUrl, // Add the image URL here
    });

    // Clear the controllers and reset the selected date and time
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();

    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedTags.clear(); // Clear the selected tags
      _image = null; // Clear the selected image
    });
  }

  Future<void> _showProfileOptions(BuildContext context, String userEmail) async {
    final action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Iconsax.user),
                title: Text('View Profile'),
                onTap: () {
                  Navigator.pop(context, 'view');
                },
              ),
              ListTile(
                leading: Icon(Iconsax.logout),
                title: Text('Log Out'),
                onTap: () {
                  Navigator.pop(context, 'logout');
                },
              ),
            ],
          ),
        );
      },
    );

    if (action == 'logout') {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));
    } else if (action == 'view') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: userEmail)));
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
