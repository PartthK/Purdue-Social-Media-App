import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _hasRSVPed = false;
  String? _userId;
  late int _currentRSVPCount;

  @override
  void initState() {
    super.initState();
    _currentRSVPCount = widget.event.rsvpCount;
    _fetchUserIdAndCheckRSVP();
  }

  Future<void> _fetchUserIdAndCheckRSVP() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.email;

      if (_userId != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        List<dynamic> rsvpEvents = userSnapshot['rsvpEvents'] ?? [];

        setState(() {
          _hasRSVPed = rsvpEvents.contains(widget.event.documentId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${widget.event.title}'),
            Text('Created By: ${widget.event.createdBy}'),
            Text('RSVP Count: $_currentRSVPCount'),
            Text('Date: ${widget.event.date}'),
            Text('Description: ${widget.event.description}'),
            RichText(
              text: TextSpan(
                text: 'Location: ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.event.location,
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${widget.event.location}");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                  ),
                ],
              ),
            ),
            Text('Username: ${widget.event.username}'),
            SizedBox(height: 20),
            Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.event.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (!_hasRSVPed)
              ElevatedButton(
                onPressed: () => _incrementRSVPCount(widget.event.documentId),
                child: Text('RSVP'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  textStyle: TextStyle(fontSize: 16),
                ),
              )
            else
              Text(
                'You have already RSVPed to this event.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _incrementRSVPCount(String documentId) async {
    if (_userId != null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc(documentId);
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(_userId);

        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot['rsvpEvents'].contains(documentId)) {
          int newRSVPCount = eventSnapshot['rsvpCount'] + 1;
          transaction.update(eventRef, {'rsvpCount': newRSVPCount});
          transaction.update(userRef, {
            'rsvpEvents': FieldValue.arrayUnion([documentId])
          });
        }
      }).then((_) {
        setState(() {
          _currentRSVPCount += 1;
          _hasRSVPed = true;
        });
      }).catchError((error) {
        print("Failed to RSVP: $error");
      });
    }
  }
}

void showEventDetails(BuildContext context, Event event) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EventDetailScreen(event: event),
  );
}


