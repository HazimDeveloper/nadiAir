import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeatherData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _weatherData = await WeatherService.getCurrentWeather();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}