import 'package:flutter/material.dart';
import 'theme.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;  // Example setting for dark mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontFamily: 'Montserrat')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
            SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(fontFamily: 'Montserrat')),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // Apply the theme change or other related actions here
              },
            ),
            SizedBox(height: 20.0),
            Text('Other Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
            ListTile(
              title: Text('Setting 1', style: TextStyle(fontFamily: 'Montserrat')),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle setting tap
              },
            ),
            ListTile(
              title: Text('Setting 2', style: TextStyle(fontFamily: 'Montserrat')),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Handle setting tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
