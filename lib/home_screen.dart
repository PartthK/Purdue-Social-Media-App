import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_provider.dart';
import 'event_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

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
  final TextEditingController _createdByController = TextEditingController();
  final TextEditingController _locationMapController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Predefined event tags
  final List<String> _predefinedTags = [
    'Music', 'Tech', 'Art', 'Sports', 'Education', 'Health', 'Networking',
    'Gaming', 'Food', 'Travel', 'Fashion', 'Business', 'Charity', 'Science',
    'History', 'Culture', 'Photography', 'Literature', 'Comedy', 'Theater'
  ];

  // Selected tags by user
  final Set<String> _selectedTags = Set();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDarkMode = themeData.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Events'
              : _selectedIndex == 1
              ? 'Search'
              : _selectedIndex == 2
              ? 'Notifications'
              : 'Settings',
          style: GoogleFonts.montserrat(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Color(0xfff3f1f7),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: isDarkMode ? Colors.black : Color(0xfff3f1f7),
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Iconsax.sidebar_right,
              size: 30.0,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.user,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => _showProfileOptions(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                margin: EdgeInsets.only(bottom: 0),
                padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'BoilerVibe',
                    style: GoogleFonts.montserrat(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(
                Iconsax.home,
                'Home',
                0,
                Colors.blue,
                Color(0xFFE0F7FA),
                isDarkMode,
              ),
              _buildDrawerItem(
                Iconsax.search_normal,
                'Search',
                1,
                Colors.deepPurple,
                Color(0xFFEFE1FF),
                isDarkMode,
              ),
              _buildDrawerItem(
                Iconsax.notification,
                'Notifications',
                2,
                Colors.pink,
                Color(0xFFFFEBEE),
                isDarkMode,
              ),
              _buildDrawerItem(
                Iconsax.profile,
                'Profile',
                3,
                Colors.green,
                Color(0xFFE8F5E9),
                isDarkMode,
              ),
              ListTile(
                leading: Icon(Iconsax.shield_tick, color: isDarkMode ? Colors.white : Colors.black),
                title: Text(
                  'Privacy Policy',
                  style: GoogleFonts.montserrat(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _launchURL('https://sites.google.com/view/boilervibe-app/privacy-policy'),
              ),
              ListTile(
                leading: Icon(Iconsax.document, color: isDarkMode ? Colors.white : Colors.black),
                title: Text(
                  'Terms of Use',
                  style: GoogleFonts.montserrat(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _launchURL('https://sites.google.com/view/boilervibe-app/terms-of-use'),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventScreen(),
          SearchScreen(),
          NotificationsScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => _showAddEventModal(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: themeData.primaryColor,
      )
          : null,
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black87 : Color(0xe8f3f1f7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
          items: [
            SalomonBottomBarItem(
              icon: Icon(Iconsax.home, size: 24.0),
              title: Text(
                'Home',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: isDarkMode ? Colors.white : Colors.black,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.search_normal, size: 24.0),
              title: Text(
                'Search',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: Colors.deepPurple,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.notification, size: 24.0),
              title: Text(
                'Notifications',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: Colors.pink,
            ),
            SalomonBottomBarItem(
              icon: Icon(Iconsax.profile, size: 24.0),
              title: Text(
                'Profile',
                style: GoogleFonts.montserrat(
                  fontSize: 12.0,
                  fontWeight: _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selectedColor: Colors.green,
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
          color: _selectedIndex == index ? bubbleColor : null,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showProfileOptions(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                      (route) => false,
                );
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showAddEventModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add Event',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Event Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Event Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _createdByController,
                        decoration: InputDecoration(
                          labelText: 'Created By',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        controller: _locationMapController,
                        decoration: InputDecoration(
                          labelText: 'Location Map URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text('Select Date'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Time: ${_selectedTime.format(context)}'),
                          TextButton(
                            onPressed: () => _selectTime(context),
                            child: Text('Select Time'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Wrap(
                        spacing: 8.0,
                        children: _predefinedTags.map((tag) {
                          return ChoiceChip(
                            label: Text(tag),
                            selected: _selectedTags.contains(tag),
                            onSelected: (bool selected) {
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
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_titleController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty &&
                              _locationController.text.isNotEmpty &&
                              _selectedTags.length >= 3) {
                            FirebaseFirestore.instance.collection('events').add({
                              'title': _titleController.text,
                              'description': _descriptionController.text,
                              'location': _locationController.text,
                              'createdBy': _createdByController.text,
                              'locationMap': _locationMapController.text,
                              'date': _selectedDate.toIso8601String(),
                              'time': _selectedTime.format(context),
                              'tags': _selectedTags.toList(),
                              'username': _usernameController.text,
                            });
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill all fields and select at least 3 tags.')),
                            );
                          }
                        },
                        child: Text('Add Event'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
