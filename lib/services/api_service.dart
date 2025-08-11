// services/api_service.dart (Updated with Gemini Integration)
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:nadiair/services/gemini_services.dart';
import '../models/water_analysis.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.169:8000'; // Backup backend URL
  
  static Future<WaterAnalysis> analyzeWater(File imageFile) async {
    try {
      // Initialize Gemini service
      GeminiService.initialize();
      
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Use Gemini for automatic classification
      final geminiResult = await GeminiService.analyzeWaterImageWithClassification(imageBytes);
      
      // Get recommendation from Gemini
      final tempAnalysis = WaterAnalysis(
        success: true,
        waterQualityClass: geminiResult['water_quality_class'],
        category: WaterAnalysis.parseCategory(geminiResult['category']),
        confidence: geminiResult['confidence'],
        waterDetected: geminiResult['water_detected'],
        message: 'Analisis selesai menggunakan AI',
        recommendation: '',
        explanation: geminiResult['explanation'],
        timestamp: DateTime.now(),
      );
      
      final recommendation = await GeminiService.getWaterRecommendation(tempAnalysis);
      
      // Create final analysis with all data
      return WaterAnalysis(
        success: true,
        waterQualityClass: geminiResult['water_quality_class'],
        category: WaterAnalysis.parseCategory(geminiResult['category']),
        confidence: geminiResult['confidence'],
        waterDetected: geminiResult['water_detected'],
        message: 'Analisis selesai menggunakan AI',
        recommendation: recommendation,
        explanation: geminiResult['explanation'],
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      print('Error in Gemini analysis: $e');
      // Fallback to backend if Gemini fails
      return await _analyzeWaterWithBackend(imageFile);
    }
  }
  
  // Backup method using backend server
  static Future<WaterAnalysis> _analyzeWaterWithBackend(File imageFile) async {
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
        // Convert old format to new format
        return WaterAnalysis(
          success: data['success'] ?? true,
          waterQualityClass: data['water_quality_class'] ?? 'Sederhana',
          category: WaterAnalysis.parseCategory('OPTIMUM'), // Default category
          confidence: (data['confidence'] ?? 70).toDouble(),
          waterDetected: data['water_detected'] ?? true,
          message: data['message'] ?? 'Analisis selesai',
          recommendation: data['recommendation'] ?? 'Tiada cadangan khusus.',
          explanation: 'Analisis menggunakan backend server.',
          timestamp: DateTime.parse(data['analysis_timestamp'] ?? DateTime.now().toIso8601String()),
        );
      } else {
        throw Exception('Backend analysis failed: ${data['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Final fallback - return default analysis
      return WaterAnalysis(
        success: false,
        waterQualityClass: 'Tidak Diketahui',
        category: WaterAnalysis.parseCategory('OPTIMUM'),
        confidence: 0.0,
        waterDetected: false,
        message: 'Ralat analisis: $e',
        recommendation: 'Sila cuba lagi atau periksa sambungan internet.',
        explanation: 'Tidak dapat menganalisis gambar pada masa ini.',
        timestamp: DateTime.now(),
      );
    }
  }
}