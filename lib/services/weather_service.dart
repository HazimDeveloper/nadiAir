// services/weather_service.dart (Updated)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String openWeatherApiKey = 'd7da05b2d5f4e04296eb82d682ac6182';
  static const String googleApiKey = 'AIzaSyBAu5LXTH6xw4BrThroxWxngNunfgh27bg';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  static Future<WeatherData> getCurrentWeather() async {
    try {
      // Get current location
      Position position = await _getCurrentPosition();
      
      // Get weather data from OpenWeatherMap
      final weatherResponse = await http.get(
        Uri.parse('$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$openWeatherApiKey&units=metric&lang=ms'),
      );
      
      // Get air quality from Google Air Quality API
      final airQualityResponse = await http.post(
        Uri.parse('https://airquality.googleapis.com/v1/currentConditions:lookup?key=$googleApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          }
        }),
      );
      
      if (weatherResponse.statusCode == 200) {
        var weatherData = json.decode(weatherResponse.body);
        var airQualityData = airQualityResponse.statusCode == 200 
            ? json.decode(airQualityResponse.body) 
            : null;
        
        return WeatherData.fromJson(weatherData, airQualityData);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Weather service error: $e');
    }
  }
  
  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Default to Kuala Terengganu if location service disabled
      return Position(
        latitude: 5.3302,
        longitude: 103.1408,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Default location if permission denied
        return Position(
          latitude: 5.3302,
          longitude: 103.1408,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Default location if permission permanently denied
      return Position(
        latitude: 5.3302,
        longitude: 103.1408,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    
    return await Geolocator.getCurrentPosition();
  }
}