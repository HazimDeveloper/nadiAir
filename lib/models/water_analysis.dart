import 'package:flutter/material.dart';

// Enum untuk kategori kualiti air
enum WaterQualityCategory {
  HIGH_PH,
  HIGH_PH_LOW_TEMP,
  LOW_PH,
  LOW_TEMP_HIGH_PH,
  LOW_TEMP,
  OPTIMUM
}

class WaterAnalysis {
  final bool success;
  final String waterQualityClass;
  final WaterQualityCategory category;
  final double confidence;
  final bool waterDetected;
  final String message;
  final String recommendation;
  final String explanation;
  final DateTime timestamp;

  WaterAnalysis({
    required this.success,
    required this.waterQualityClass,
    required this.category,
    required this.confidence,
    required this.waterDetected,
    required this.message,
    required this.recommendation,
    required this.explanation,
    required this.timestamp,
  });

  factory WaterAnalysis.fromJson(Map<String, dynamic> json) {
    return WaterAnalysis(
      success: json['success'] ?? false,
      waterQualityClass: json['water_quality_class'] ?? 'Unknown',
      category: parseCategory(json['category'] ?? 'OPTIMUM'),
      confidence: (json['confidence'] ?? 0).toDouble(),
      waterDetected: json['water_detected'] ?? false,
      message: json['message'] ?? '',
      recommendation: json['recommendation'] ?? '',
      explanation: json['explanation'] ?? '',
      timestamp: DateTime.parse(json['analysis_timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  static WaterQualityCategory parseCategory(String categoryStr) {
    switch (categoryStr.toUpperCase()) {
      case 'HIGH_PH':
        return WaterQualityCategory.HIGH_PH;
      case 'HIGH_PH_LOW_TEMP':
        return WaterQualityCategory.HIGH_PH_LOW_TEMP;
      case 'LOW_PH':
        return WaterQualityCategory.LOW_PH;
      case 'LOW_TEMP_HIGH_PH':
        return WaterQualityCategory.LOW_TEMP_HIGH_PH;
      case 'LOW_TEMP':
        return WaterQualityCategory.LOW_TEMP;
      case 'OPTIMUM':
      default:
        return WaterQualityCategory.OPTIMUM;
    }
  }

  Color get qualityColor {
    switch (category) {
      case WaterQualityCategory.OPTIMUM:
        return const Color(0xFF4CAF50); // Green
      case WaterQualityCategory.HIGH_PH:
      case WaterQualityCategory.LOW_PH:
        return const Color(0xFFFF9800); // Orange
      case WaterQualityCategory.HIGH_PH_LOW_TEMP:
      case WaterQualityCategory.LOW_TEMP_HIGH_PH:
      case WaterQualityCategory.LOW_TEMP:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String get qualityMalay {
    switch (category) {
      case WaterQualityCategory.HIGH_PH:
        return 'pH Tinggi';
      case WaterQualityCategory.HIGH_PH_LOW_TEMP:
        return 'pH Tinggi, Suhu Rendah';
      case WaterQualityCategory.LOW_PH:
        return 'pH Rendah';
      case WaterQualityCategory.LOW_TEMP_HIGH_PH:
        return 'Suhu Rendah, pH Tinggi';
      case WaterQualityCategory.LOW_TEMP:
        return 'Suhu Rendah';
      case WaterQualityCategory.OPTIMUM:
        return 'Optimum';
      default:
        return 'Tidak Diketahui';
    }
  }

  String get categoryDescription {
    switch (category) {
      case WaterQualityCategory.HIGH_PH:
        return 'Air menunjukkan tahap pH yang tinggi';
      case WaterQualityCategory.HIGH_PH_LOW_TEMP:
        return 'Air menunjukkan pH tinggi dengan suhu rendah';
      case WaterQualityCategory.LOW_PH:
        return 'Air menunjukkan tahap pH yang rendah';
      case WaterQualityCategory.LOW_TEMP_HIGH_PH:
        return 'Air menunjukkan suhu rendah dengan pH tinggi';
      case WaterQualityCategory.LOW_TEMP:
        return 'Air menunjukkan suhu yang rendah';
      case WaterQualityCategory.OPTIMUM:
        return 'Air berada dalam keadaan optimum';
      default:
        return 'Status air tidak dapat ditentukan';
    }
  }
}