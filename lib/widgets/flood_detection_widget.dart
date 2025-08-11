// widgets/flood_detection_widget.dart - Automated Flood Risk Detection
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';

class FloodDetectionWidget extends StatefulWidget {
  const FloodDetectionWidget({super.key});

  @override
  State<FloodDetectionWidget> createState() => _FloodDetectionWidgetState();
}

class _FloodDetectionWidgetState extends State<FloodDetectionWidget> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  String _floodRisk = 'SEDANG MENGANALISIS';
  Color _riskColor = Colors.orange;
  IconData _riskIcon = Icons.analytics_rounded;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _startAnalysis();
  }

  void _startAnalysis() {
    _pulseController.repeat(reverse: true);
    
    // Simulate flood risk analysis based on weather data
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _analyzeFloodRisk();
      }
    });
  }

  void _analyzeFloodRisk() {
    final weatherProvider = context.read<WeatherProvider>();
    final weather = weatherProvider.weatherData;
    
    if (weather != null) {
      String risk;
      Color color;
      IconData icon;
      
      // Determine flood risk based on humidity, temperature, and conditions
      if (weather.humidity > 80 && weather.condition.toLowerCase().contains('hujan')) {
        risk = 'TINGGI';
        color = Colors.red;
        icon = Icons.warning_rounded;
      } else if (weather.humidity > 60 && 
                 (weather.condition.toLowerCase().contains('awan') || 
                  weather.condition.toLowerCase().contains('cloud'))) {
        risk = 'SEDERHANA';
        color = Colors.orange;
        icon = Icons.cloud_rounded;
      } else {
        risk = 'RENDAH';
        color = Colors.green;
        icon = Icons.shield_rounded;
      }
      
      setState(() {
        _floodRisk = risk;
        _riskColor = color;
        _riskIcon = icon;
        _isAnalyzing = false;
      });
      
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.water_rounded,
                    color: const Color(0xFF1976D2),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:                   Text(
                    'Risiko Banjir',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Risk Level Display
            Expanded(
              child: Column(
                children: [
                  // Risk Icon and Level
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _riskColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _riskColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _riskIcon,
                                  color: _riskColor,
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        ),
                        
                                                  
                        const SizedBox(height: 8),
                        
                        Text(
                          _floodRisk,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _riskColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (!_isAnalyzing) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getRiskDescription(),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Action Button or Status
                  if (_isAnalyzing)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Menganalisis...',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _showFloodDetails,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _riskColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _riskColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: _riskColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskDescription() {
    switch (_floodRisk) {
      case 'TINGGI':
        return 'Berhati-hati\nPantau kawasan';
      case 'SEDERHANA':
        return 'Biasa sahaja\nPantau cuaca';
      case 'RENDAH':
        return 'Selamat\nKeadaan normal';
      default:
        return 'Mengkira...';
    }
  }

  void _showFloodDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _riskIcon,
                      color: _riskColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analisis Risiko Banjir',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Risiko: $_floodRisk',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _riskColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Details
              Expanded(
                child: Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    final weather = weatherProvider.weatherData;
                    
                    return Column(
                      children: [
                        // Weather factors
                        _buildFactorCard(
                          'Kelembapan Udara',
                          '${weather?.humidity ?? 0}%',
                          weather != null && weather.humidity > 70 
                              ? 'Tinggi - Risiko hujan meningkat'
                              : 'Normal - Keadaan stabil',
                          weather != null && weather.humidity > 70 
                              ? Colors.orange : Colors.green,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildFactorCard(
                          'Kondisi Cuaca',
                          weather?.condition ?? 'Tidak diketahui',
                          weather?.condition.toLowerCase().contains('hujan') == true
                              ? 'Hujan aktif - Pantau paras air'
                              : 'Cuaca stabil',
                          weather?.condition.toLowerCase().contains('hujan') == true
                              ? Colors.red : Colors.green,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recommendations
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_rounded,
                                    color: Colors.amber[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cadangan Tindakan:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getRecommendations(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactorCard(String title, String value, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendations() {
    switch (_floodRisk) {
      case 'TINGGI':
        return '• Pantau amaran cuaca secara berkala\n• Elak kawasan rendah dan mudah banjir\n• Sediakan pelan pemindahan kecemasan\n• Simpan bekalan makanan dan air';
      case 'SEDERHANA':
        return '• Pantau ramalan cuaca\n• Periksa sistem saliran kawasan rumah\n• Sediakan kit kecemasan asas\n• Ikuti berita tempatan';
      case 'RENDAH':
        return '• Keadaan cuaca stabil\n• Lakukan aktiviti harian seperti biasa\n• Pantau cuaca secara umum\n• Pastikan sistem saliran berfungsi';
      default:
        return '• Pantau analisis untuk maklumat terkini';
    }
  }
}