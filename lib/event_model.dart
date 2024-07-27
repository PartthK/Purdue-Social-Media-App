import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String documentId;
  final String createdBy;
  final int rsvpCount;
  final DateTime date;
  final String description;
  final String location;
  final String locationMap;
  final String title;
  final String username;
  final List<String> eventTags; // New property for event tags

  Event({
    required this.documentId,
    required this.createdBy,
    required this.rsvpCount,
    required this.date,
    required this.description,
    required this.location,
    required this.locationMap,
    required this.title,
    required this.username,
    required this.eventTags, // Initialize the new property
  });

  factory Event.fromJson(String id, Map<String, dynamic> json) {
    return Event(
      documentId: id,
      createdBy: json['createdBy'] ?? '',
      rsvpCount: json['rsvpCount'] ?? 0,
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      locationMap: json['locationMap'] ?? '',
      title: json['title'] ?? '',
      username: json['username'] ?? '',
      eventTags: List<String>.from(json['eventTags'] ?? []), // Parse the tags from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdBy': createdBy,
      'rsvpCount': rsvpCount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'location': location,
      'locationMap': locationMap,
      'title': title,
      'username': username,
      'eventTags': eventTags, // Include the tags in the JSON representation
    };
  }
}
