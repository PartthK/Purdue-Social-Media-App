import 'package:flutter/material.dart';
import 'theme.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 10,  // Sample number of notifications
          itemBuilder: (context, index) {
            return Card(
              elevation: 2.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Notification $index', style: TextStyle(fontFamily: 'Montserrat')),
                subtitle: Text('Details for notification $index', style: TextStyle(fontFamily: 'Montserrat')),
              ),
            );
          },
        ),
      ),
    );
  }
}
