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
    };
  }
}