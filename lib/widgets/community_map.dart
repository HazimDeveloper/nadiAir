import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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

        return GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          initialCameraPosition: const CameraPosition(
            target: _defaultLocation,
            zoom: 12,
          ),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      },
    );
  }

  double _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'tinggi':
        return BitmapDescriptor.hueRed;
      case 'medium':
      case 'sederhana':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueGreen;
    }
  }
}