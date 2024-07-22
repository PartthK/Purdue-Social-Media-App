import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_model.dart';
import 'auth_provider.dart'; // Assuming you have this provider for authentication

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _hasRSVPed = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndCheckRSVP();
  }

  Future<void> _fetchUserIdAndCheckRSVP() async {
    // Assuming you have a method to get the current user's email
    String? userEmail = await _getUserEmail();

    if (userEmail != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();

      if (userSnapshot.exists) {
        setState(() {
          _userId = userSnapshot.id;
        });

        DocumentSnapshot rsvpSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event.documentId)
            .collection('rsvps')
            .doc(_userId)
            .get();

        setState(() {
          _hasRSVPed = rsvpSnapshot.exists;
        });
      }
    }
  }

  Future<String?> _getUserEmail() async {
    // Fetch the current user's email from your authentication provider
    // This is just a placeholder. Replace it with actual code to get the user email.
    // For example, if using FirebaseAuth:
    // return FirebaseAuth.instance.currentUser?.email;

    // For the purpose of this example, returning a placeholder email
    return 'kulka142@purdue.edu'; // Replace with actual method to get current user email
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
            Text('RSVP Count: ${widget.event.rsvpCount}'),
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
            if (widget.event.locationMap.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(widget.event.locationMap);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  'Open Location in Google Maps',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            SizedBox(height: 20),
            if (!_hasRSVPed)
              ElevatedButton(
                onPressed: () => _incrementRSVPCount(widget.event.documentId, widget.event.rsvpCount),
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

  void _incrementRSVPCount(String documentId, int currentCount) async {
    if (_userId != null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc(documentId);

        // Increment the RSVP count
        transaction.update(eventRef, {'rsvpCount': currentCount + 1});

        // Add the user to the RSVPs sub-collection
        DocumentReference rsvpRef = eventRef.collection('rsvps').doc(_userId);
        transaction.set(rsvpRef, {'timestamp': FieldValue.serverTimestamp()});
      });

      setState(() {
        _hasRSVPed = true;
      });
    }
  }
}
