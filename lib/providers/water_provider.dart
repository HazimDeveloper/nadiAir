import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/water_analysis.dart';

class WaterProvider with ChangeNotifier {
  WaterAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _error;
  File? _currentImage;

  WaterAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get currentImage => _currentImage;

  Future<void> scanWater(ImageSource source) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _currentImage = File(pickedFile.path);
        
        final analysis = await ApiService.analyzeWater(_currentImage!);
        _currentAnalysis = analysis;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAnalysis() {
    _currentAnalysis = null;
    _currentImage = null;
    _error = null;
    notifyListeners();
  }
}