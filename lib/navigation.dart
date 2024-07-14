import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'theme.dart';  // Add this import

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Search Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Notifications Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Center(child: Text('Settings Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),  // Adjust padding as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // Center the items
          children: [
            SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                SalomonBottomBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Home'),
                  selectedColor: Colors.purple,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.search),
                  title: Text('Search'),
                  selectedColor: Colors.orange,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.notifications),
                  title: Text('Notifications'),
                  selectedColor: Colors.red,
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.settings),
                  title: Text('Settings'),
                  selectedColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
