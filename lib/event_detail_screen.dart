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
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  widget.event.title,
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('MMM d, y - h:mm a').format(widget.event.date)),
                  _buildInfoRow(Icons.location_on, 'Location', widget.event.location),
                  _buildInfoRow(Icons.person, 'Created by', widget.event.createdBy),
                  _buildInfoRow(Icons.group, 'RSVP Count', '$_currentRSVPCount'),
                  SizedBox(height: 16),
                  Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(widget.event.description),
                  SizedBox(height: 16),
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
                      onPressed: () => _incrementRSVPCount(widget.event.documentId),
                      child: Text('RSVP'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    )
                  else
                    Text(
                      'You have already RSVPed to this event.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
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
