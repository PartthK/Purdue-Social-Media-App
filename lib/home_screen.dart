import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<String> _allTags = [ 'Tech', 'AI/ML', 'Music', 'Biology', 'Physics', 'Chemistry', 'Sports', 'Art',
    'Literature', 'Dance', 'Theatre', 'Film', 'Photography', 'Travel', 'Cooking',
    'Fashion', 'Finance', 'Entrepreneurship', 'Gaming', 'Fitness'];
  List<String> _selectedTags = [];


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
            icon: Icon(Iconsax.search_normal),
            onPressed: () => _showProfileOptions(context, userEmail),
          ),
          IconButton(
            icon: Icon(Iconsax.user),
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
                    child: Align(
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
            Positioned(
              top: 8,
              right: 8,
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
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventScreen(),
          SearchScreen(),
          if (userEmail.isNotEmpty) NotificationsScreen(userId: userEmail), // Pass the actual userId
          if (userEmail.isNotEmpty) ProfileScreen(userId: userEmail), // Pass the actual userId
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
              color: Colors.grey, // Thin grey border
              width: 0.2, // Adjust the width as needed
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
          itemPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, Color selectedColor, Color bubbleColor, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors.white : Colors.black),
      ),
      title: Container(
        decoration: BoxDecoration(
          color: _selectedIndex == index ? bubbleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: _selectedIndex == index
                ? selectedColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddEventModal(BuildContext context) {
    showModalBottomSheet(
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
                  // Tag Selection
                  Text(
                    'Tags:',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: _allTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _addEvent(); // Call _addEvent to save the event and update Firestore
                      Navigator.pop(context); // Close the modal
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Border radius
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Button size
                    ),
                    child: Text(
                      'Save Event',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.0, // Font size
                        fontWeight: FontWeight.bold, // Bold text
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


  void _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ??
        initialDate;

    setState(() {
      _selectedDate = newDate;
    });
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    ) ??
        initialTime;

    setState(() {
      _selectedTime = newTime;
    });
  }

  void _addEvent() async {
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
      'tags': _selectedTags, // Add the selected tags here
    });

    // Clear the controllers and reset the selected date and time
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();

    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedTags.clear(); // Clear the selected tags
    });
  }


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showProfileOptions(BuildContext context, String userEmail) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Iconsax.user, color: Theme.of(context).primaryColor),
                title: Text('View Profile', style: GoogleFonts.montserrat()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: userEmail)), // Replace with actual userId
                  );
                },
              ),
              ListTile(
                leading: Icon(Iconsax.logout, color: Colors.red),
                title: Text('Logout', style: GoogleFonts.montserrat(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}