import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'event_detail_screen.dart';
import 'event_model.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Event event = Event.fromJson(document.id, document.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(
                  event.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title: ${event.title}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      'Date: ${event.date.toString()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      'Created By: ${event.createdBy}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      'Description: ${event.description}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
