import 'package:flutter/material.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int airQualityIndex;
  final String airQualityLevel;
  final String location;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.airQualityIndex,
    required this.airQualityLevel,
    required this.location,
  });

  factory WeatherData.fromJson(Map<String, dynamic> weatherJson, Map<String, dynamic>? airQualityJson) {
    int aqi = 1; // Default good air quality
    
    if (airQualityJson != null && airQualityJson.containsKey('indexes')) {
      try {
        aqi = airQualityJson['indexes'][0]['aqi'] ?? 1;
      } catch (e) {
        // Keep default if parsing fails
      }
    }
    
    return WeatherData(
      temperature: (weatherJson['main']['temp'] ?? 25.0).toDouble(),
      condition: weatherJson['weather'][0]['description'] ?? 'Cerah',
      humidity: weatherJson['main']['humidity'] ?? 70,
      windSpeed: (weatherJson['wind']['speed'] ?? 5.0).toDouble(),
      airQualityIndex: aqi,
      airQualityLevel: _getAirQualityLevel(aqi),
      location: weatherJson['name'] ?? 'Lokasi Tidak Diketahui',
    );
  }

  static String _getAirQualityLevel(int aqi) {
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sederhana';
    if (aqi <= 150) return 'Tidak Sihat untuk Sensitif';
    if (aqi <= 200) return 'Tidak Sihat';
    if (aqi <= 300) return 'Sangat Tidak Sihat';
    return 'Berbahaya';
  }

  Color get airQualityColor {
    if (airQualityIndex <= 50) return Colors.green;
    if (airQualityIndex <= 100) return Colors.yellow;
    if (airQualityIndex <= 150) return Colors.orange;
    if (airQualityIndex <= 200) return Colors.red;
    if (airQualityIndex <= 300) return Colors.purple;
    return Colors.brown;
  }
}