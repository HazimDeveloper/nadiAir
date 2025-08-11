import 'package:cloud_firestore/cloud_firestore.dart';

class WaterReport {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String severity;
  final DateTime timestamp;
  final String? imageUrl;

  WaterReport({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.timestamp,
    this.imageUrl,
  });

  factory WaterReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WaterReport(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      severity: data['severity'] ?? 'Low',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
    };
  }
}