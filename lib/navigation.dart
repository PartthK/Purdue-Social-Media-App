import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'theme.dart';  // Add this import

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;
  bool isDarkMode = false; // Add logic to detect dark mode

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Search Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Notifications Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Settings Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Stack(
        children: [
          Positioned(
            bottom: 10.0,
            left: MediaQuery.of(context).size.width / 8,  // Adjust position to center the fixed width bar
            right: MediaQuery.of(context).size.width / 8, // Adjust position to center the fixed width bar
            child: Container(
              height: 70.0,
              width: MediaQuery.of(context).size.width * 0.75,  // Fixed width of the bottom navigation bar
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black87 : Color(0xe8f3f1f7),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: SalomonBottomBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
                selectedItemColor: isDarkMode ? Colors.white : Colors.black,
                unselectedItemColor: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                items: [
                  SalomonBottomBarItem(
                    icon: Icon(Iconsax.home),
                    title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    selectedColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  SalomonBottomBarItem(
                    icon: Icon(Iconsax.search_normal),
                    title: Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                    selectedColor: Colors.orange,
                  ),
                  SalomonBottomBarItem(
                    icon: Icon(Iconsax.notification),
                    title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    selectedColor: Colors.red,
                  ),
                  SalomonBottomBarItem(
                    icon: Icon(Iconsax.setting),
                    title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                    selectedColor: Colors.green,
                  ),
                ],
                itemPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
