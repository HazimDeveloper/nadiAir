import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_report.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static Future<List<WaterReport>> getCommunityReports() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('water_reports')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => WaterReport.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load community reports: $e');
    }
  }
  
  static Future<void> submitReport(WaterReport report) async {
    try {
      await _firestore.collection('water_reports').add(report.toMap());
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }
}