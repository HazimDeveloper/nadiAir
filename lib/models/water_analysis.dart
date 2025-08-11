import 'package:flutter/material.dart';

class WaterAnalysis {
  final bool success;
  final String waterQualityClass;
  final double confidence;
  final bool waterDetected;
  final String message;
  final String recommendation;
  final DateTime timestamp;

  WaterAnalysis({
    required this.success,
    required this.waterQualityClass,
    required this.confidence,
    required this.waterDetected,
    required this.message,
    required this.recommendation,
    required this.timestamp,
  });

  factory WaterAnalysis.fromJson(Map<String, dynamic> json) {
    return WaterAnalysis(
      success: json['success'] ?? false,
      waterQualityClass: json['water_quality_class'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      waterDetected: json['water_detected'] ?? false,
      message: json['message'] ?? '',
      recommendation: json['recommendation'] ?? '',
      timestamp: DateTime.parse(json['analysis_timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Color get qualityColor {
    switch (waterQualityClass.toLowerCase()) {
      case 'clean':
      case 'bersih':
        return const Color(0xFF4CAF50); // Green
      case 'moderate':
      case 'sederhana':
        return const Color(0xFFFF9800); // Orange
      case 'poor':
      case 'tercemar':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String get qualityMalay {
    switch (waterQualityClass.toLowerCase()) {
      case 'clean':
        return 'Bersih';
      case 'moderate':
        return 'Sederhana';
      case 'poor':
        return 'Tercemar';
      default:
        return 'Tidak Diketahui';
    }
  }
}