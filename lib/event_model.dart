// event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  factory Event.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      location: data['location'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date,
    };
  }
}

class EventService {
  final CollectionReference eventCollection = FirebaseFirestore.instance.collection('events');

  Stream<List<Event>> getEvents() {
    return eventCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromDocument(doc);
      }).toList();
    });
  }

  Future<void> addEvent(Event event) async {
    await eventCollection.doc(event.id).set(event.toMap());
  }
}
