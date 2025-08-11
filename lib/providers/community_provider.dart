// providers/community_provider.dart (Updated)
import 'package:flutter/material.dart';
import 'package:nadiair/services/gemini_services.dart';
import '../services/firebase_service.dart';
import '../models/water_report.dart';

class CommunityProvider with ChangeNotifier {
  List<WaterReport> _reports = [];
  bool _isLoading = false;
  String? _error;
  String? _communityAdvice;
  bool _isLoadingAdvice = false;

  List<WaterReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get communityAdvice => _communityAdvice;
  bool get isLoadingAdvice => _isLoadingAdvice;

  Future<void> loadCommunityData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _reports = await FirebaseService.getCommunityReports();
      
      // Get community advice based on recent reports
      if (_reports.isNotEmpty) {
        await _loadCommunityAdvice();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCommunityAdvice() async {
    try {
      _isLoadingAdvice = true;
      notifyListeners();

      // Analyze recent reports to get community advice
      final recentIssues = _reports.take(5).map((r) => r.title).toList();
      final location = _reports.isNotEmpty ? _reports.first.location : 'Terengganu';
      
      if (recentIssues.isNotEmpty) {
        _communityAdvice = await GeminiService.getCommunityAdvice(
          recentIssues.join(', '), 
          location
        );
      }
    } catch (e) {
      // Silently fail for advice loading
    } finally {
      _isLoadingAdvice = false;
      notifyListeners();
    }
  }

  Future<void> submitReport(WaterReport report) async {
    try {
      await FirebaseService.submitReport(report);
      await loadCommunityData(); // Refresh data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}