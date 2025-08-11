import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/community_provider.dart';

class CommunityMap extends StatefulWidget {
  const CommunityMap({super.key});

  @override
  State<CommunityMap> createState() => _CommunityMapState();
}

class _CommunityMapState extends State<CommunityMap> {
  GoogleMapController? _controller;
  
  static const LatLng _defaultLocation = LatLng(5.3302, 103.1408); // Kuala Terengganu

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        Set<Marker> markers = {};
        
        // Add markers for reports
        for (var report in communityProvider.reports) {
          markers.add(
            Marker(
              markerId: MarkerId(report.id),
              position: LatLng(report.latitude, report.longitude),
              infoWindow: InfoWindow(
                title: report.title,
                snippet: report.description,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getSeverityColor(report.severity),
              ),
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // We'll create custom button
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              style: _mapStyle,
            ),
            
            // Custom Controls
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // My Location Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _goToMyLocation,
                      icon: Icon(
                        Icons.my_location_rounded,
                        color: const Color(0xFF1976D2),
                      ),
                      tooltip: 'Lokasi Saya',
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Zoom In Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _zoomIn,
                      icon: Icon(
                        Icons.add_rounded,
                        color: const Color(0xFF1976D2),
                      ),
                      tooltip: 'Zoom Masuk',
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Zoom Out Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _zoomOut,
                      icon: Icon(
                        Icons.remove_rounded,
                        color: const Color(0xFF1976D2),
                      ),
                      tooltip: 'Zoom Keluar',
                    ),
                  ),
                ],
              ),
            ),
            
            // Map Legend
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Keutamaan Masalah',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem('Kritikal', Colors.red),
                    _buildLegendItem('Sederhana', Colors.orange),
                    _buildLegendItem('Rendah', Colors.green),
                  ],
                ),
              ),
            ),
            
            // Loading overlay
            if (communityProvider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF1976D2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Memuat data laporan...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  double _getSeverityColor(String severity) {
    // Map water problems to colors based on urgency
    switch (severity.toLowerCase()) {
      case 'tiada bekalan air':
      case 'paip rosak/bocor':
      case 'sistem saliran tersumbat':
        return BitmapDescriptor.hueRed; // High priority
      case 'air kotor/keruh':
      case 'air berbau':
      case 'air berwarna':
      case 'tekanan air lemah':
        return BitmapDescriptor.hueOrange; // Medium priority
      case 'air berasa pelik':
      case 'masalah meter air':
      case 'lain-lain':
        return BitmapDescriptor.hueGreen; // Lower priority
      // Legacy support for old severity levels
      case 'high':
      case 'tinggi':
        return BitmapDescriptor.hueRed;
      case 'medium':
      case 'sederhana':
        return BitmapDescriptor.hueOrange;
      case 'low':
      case 'rendah':
      default:
        return BitmapDescriptor.hueGreen;
    }
  }

  void _goToMyLocation() async {
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLng(_defaultLocation),
      );
    }
  }

  void _zoomIn() async {
    if (_controller != null) {
      await _controller!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() async {
    if (_controller != null) {
      await _controller!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  // Custom map style with blue theme
  static const String _mapStyle = '''
    [
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#1976D2"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      }
    ]
  ''';
}