// services/api_service.dart (Updated)
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nadiair/services/gemini_services.dart';
import '../models/water_analysis.dart';

class ApiService {
  static const String baseUrl = 'http://your-backend-url:8000'; // Replace with your actual backend URL
  
  static Future<WaterAnalysis> analyzeWater(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        var analysis = WaterAnalysis.fromJson(data);
        
        // Get enhanced recommendation from Gemini
        try {
          final geminiRecommendation = await GeminiService.getWaterRecommendation(analysis);
          // Create enhanced analysis with Gemini recommendation
          return WaterAnalysis(
            success: analysis.success,
            waterQualityClass: analysis.waterQualityClass,
            confidence: analysis.confidence,
            waterDetected: analysis.waterDetected,
            message: analysis.message,
            recommendation: geminiRecommendation,
            timestamp: analysis.timestamp,
          );
        } catch (e) {
          // Fallback to original recommendation if Gemini fails
          return analysis;
        }
      } else {
        throw Exception('Analysis failed: ${data['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}