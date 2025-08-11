import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/water_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/water_quality_card.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load weather data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Nadi Air',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // title: const Text(
        //   'Suara anda dalam titisan',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Info
            const WeatherInfoCard(),
            const SizedBox(height: 16),
            
            // AI Scanner Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan Nadi Air',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ambil gambar air untuk analisis kualiti',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _scanWater(ImageSource.camera),
                            icon: const Icon(Icons.camera),
                            label: const Text('Kamera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _scanWater(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galeri'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Water Quality Result
            const WaterQualityCard(),
            const SizedBox(height: 16),
            
            // Quick Actions
            const QuickActions(),
          ],
        ),
      ),
    );
  }

  Future<void> _scanWater(ImageSource source) async {
    final waterProvider = context.read<WaterProvider>();
    await waterProvider.scanWater(source);
  }
}