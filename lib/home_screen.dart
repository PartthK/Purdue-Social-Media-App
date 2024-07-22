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
                Iconsax.setting,
                'Settings',
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
          SettingsScreen(),
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
              icon: Icon(Iconsax.setting, size: 24.0),
              title: Text(
                'Settings',
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
          color: _selectedIndex == index ? bubbleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: _selectedIndex == index ? selectedColor : (isDarkMode ? Colors.white : Colors.black),
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
                  TextField(
                    controller: _createdByController,
                    decoration: InputDecoration(
                      labelText: 'Created By',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _locationMapController,
                    decoration: InputDecoration(
                      labelText: 'Location Map URL',
                      labelStyle: GoogleFonts.montserrat(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
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
    ) ?? initialDate;

    setState(() {
      _selectedDate = newDate;
    });
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    ) ?? initialTime;

    setState(() {
      _selectedTime = newTime;
    });
  }

  void _addEvent() async {
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    await events.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'createdBy': _createdByController.text,
      'locationMap': _locationMapController.text,
      'username': _usernameController.text,
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
    });

    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _createdByController.clear();
    _locationMapController.clear();
    _usernameController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showProfileOptions(BuildContext context) {
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
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Iconsax.logout, color: Colors.red),
                title: Text('Logout', style: GoogleFonts.montserrat(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await Provider.of<AuthProvider>(context, listen: false).logout();
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
