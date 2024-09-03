import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';
import 'event_model.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with SingleTickerProviderStateMixin {
  List<Event> events = [];
  List<Event> filteredEvents = [];
  TextEditingController searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterEvents();
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  void filterEvents() {
    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      setState(() {
        filteredEvents = events.where((event) {
          return event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query) ||
              event.location.toLowerCase().contains(query) ||
              event.createdBy.toLowerCase().contains(query);
        }).toList();
      });
    } else {
      setState(() {
        filteredEvents = events;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Recommended'),
          ],
        ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildUpcomingEventsPage(),
          buildRecommendedEventsPage(),
        ],
      ),
    );
  }

  Widget buildUpcomingEventsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Search Events",
              hintText: "Search by title, description, location, or username",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('date', isGreaterThanOrEqualTo: Timestamp.now())
                .orderBy('date', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No events found'));
              }

              events = snapshot.data!.docs.map((doc) {
                return Event.fromJson(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();

              if (searchController.text.isEmpty) {
                filteredEvents = events;
              }

              return ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  Event event = filteredEvents[index];
                  return EventCard(event: event);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildRecommendedEventsPage() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please sign in to see recommended events.'));
    }

    final userEmail = user.email;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('No user profile found for this email.'));
        }

        var userProfile = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
        var userTags = List<String>.from(userProfile['tags'] ?? []);

        if (userTags.isEmpty) {
          return Center(child: Text('No tags found in your profile.'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('tags', arrayContainsAny: userTags)
              .snapshots(),
          builder: (context, eventSnapshot) {
            if (eventSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (eventSnapshot.hasError) {
              return Center(child: Text('Error: ${eventSnapshot.error}'));
            }

            if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
              return Center(child: Text('No recommended events found.'));
            }

            var recommendedEvents = eventSnapshot.data!.docs.map((doc) {
              return Event.fromJson(doc.id, doc.data() as Map<String, dynamic>);
            }).toList();

            return ListView.builder(
              itemCount: recommendedEvents.length,
              itemBuilder: (context, index) {
                Event event = recommendedEvents[index];
                return EventCard(event: event);
              },
            );
          },
        );
      },
    );
  }

}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y - h:mm a').format(event.date),
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created by ${event.createdBy}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${event.rsvpCount} RSVPs',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}