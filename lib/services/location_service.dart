// services/location_service.dart - Automated Location Detection
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });

  @override
  String toString() {
    return '$city, $state';
  }
}

class LocationService {
  // Default location (Kuala Terengganu) if location services fail
  static final LocationData _defaultLocation = LocationData(
    latitude: 5.3302,
    longitude: 103.1408,
    address: 'Kuala Terengganu, Terengganu',
    city: 'Kuala Terengganu',
    state: 'Terengganu',
    country: 'Malaysia',
  );

  // Known Malaysian cities for fallback
  static final Map<String, LocationData> _knownCities = {
    'kuala lumpur': LocationData(
      latitude: 3.1390,
      longitude: 101.6869,
      address: 'Kuala Lumpur, Federal Territory',
      city: 'Kuala Lumpur',
      state: 'Federal Territory',
      country: 'Malaysia',
    ),
    'kuala terengganu': LocationData(
      latitude: 5.3302,
      longitude: 103.1408,
      address: 'Kuala Terengganu, Terengganu',
      city: 'Kuala Terengganu',
      state: 'Terengganu',
      country: 'Malaysia',
    ),
    'penang': LocationData(
      latitude: 5.4164,
      longitude: 100.3327,
      address: 'George Town, Penang',
      city: 'George Town',
      state: 'Penang',
      country: 'Malaysia',
    ),
    'johor bahru': LocationData(
      latitude: 1.4927,
      longitude: 103.7414,
      address: 'Johor Bahru, Johor',
      city: 'Johor Bahru',
      state: 'Johor',
      country: 'Malaysia',
    ),
    'ipoh': LocationData(
      latitude: 4.5975,
      longitude: 101.0901,
      address: 'Ipoh, Perak',
      city: 'Ipoh',
      state: 'Perak',
      country: 'Malaysia',
    ),
    'kota kinabalu': LocationData(
      latitude: 5.9804,
      longitude: 116.0735,
      address: 'Kota Kinabalu, Sabah',
      city: 'Kota Kinabalu',
      state: 'Sabah',
      country: 'Malaysia',
    ),
    'kuching': LocationData(
      latitude: 1.5533,
      longitude: 110.3592,
      address: 'Kuching, Sarawak',
      city: 'Kuching',
      state: 'Sarawak',
      country: 'Malaysia',
    ),
    'shah alam': LocationData(
      latitude: 3.0733,
      longitude: 101.5185,
      address: 'Shah Alam, Selangor',
      city: 'Shah Alam',
      state: 'Selangor',
      country: 'Malaysia',
    ),
  };

  /// Get current location with automatic fallback
  static Future<LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services disabled, using default location');
        return _defaultLocation;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied, using default location');
          return _defaultLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied, using default location');
        return _defaultLocation;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            address: _formatAddress(place),
            city: place.locality ?? place.subAdministrativeArea ?? 'Unknown City',
            state: place.administrativeArea ?? 'Unknown State',
            country: place.country ?? 'Malaysia',
          );
        }
      } catch (e) {
        print('Reverse geocoding failed: $e');
      }

      // If reverse geocoding fails, return coordinates with estimated location
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
        city: _estimateCityFromCoordinates(position.latitude, position.longitude),
        state: _estimateStateFromCoordinates(position.latitude, position.longitude),
        country: 'Malaysia',
      );

    } catch (e) {
      print('Error getting current location: $e');
      return _defaultLocation;
    }
  }

  /// Get location by name (for manual input)
  static Future<LocationData?> getLocationByName(String locationName) async {
    try {
      // First check our known cities
      final normalizedName = locationName.toLowerCase().trim();
      for (String cityKey in _knownCities.keys) {
        if (normalizedName.contains(cityKey) || cityKey.contains(normalizedName)) {
          return _knownCities[cityKey];
        }
      }

      // If not found in known cities, try geocoding
      List<Location> locations = await locationFromAddress('$locationName, Malaysia');
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        
        // Reverse geocode to get detailed address
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            return LocationData(
              latitude: location.latitude,
              longitude: location.longitude,
              address: _formatAddress(place),
              city: place.locality ?? place.subAdministrativeArea ?? locationName,
              state: place.administrativeArea ?? 'Unknown State',
              country: place.country ?? 'Malaysia',
            );
          }
        } catch (e) {
          print('Reverse geocoding failed for manual location: $e');
        }

        // Fallback if reverse geocoding fails
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: locationName,
          city: locationName,
          state: _estimateStateFromCoordinates(location.latitude, location.longitude),
          country: 'Malaysia',
        );
      }
    } catch (e) {
      print('Error getting location by name: $e');
    }
    
    return null;
  }

  /// Check if location services are available
  static Future<bool> isLocationServiceAvailable() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission != LocationPermission.denied && 
             permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission != LocationPermission.denied && 
             permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  /// Calculate distance between two points
  static double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Format address from placemark
  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.name != null && place.name!.isNotEmpty) {
      addressParts.add(place.name!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
  }

  /// Estimate city from coordinates (for Malaysia)
  static String _estimateCityFromCoordinates(double lat, double lng) {
    // Simple estimation based on coordinate ranges
    if (lat >= 3.0 && lat <= 3.3 && lng >= 101.5 && lng <= 101.8) {
      return 'Kuala Lumpur';
    } else if (lat >= 5.2 && lat <= 5.6 && lng >= 100.1 && lng <= 100.5) {
      return 'Penang';
    } else if (lat >= 5.0 && lat <= 5.6 && lng >= 102.8 && lng <= 103.5) {
      return 'Kuala Terengganu';
    } else if (lat >= 1.3 && lat <= 1.6 && lng >= 103.6 && lng <= 103.9) {
      return 'Johor Bahru';
    } else if (lat >= 4.4 && lat <= 4.8 && lng >= 100.8 && lng <= 101.2) {
      return 'Ipoh';
    } else if (lat >= 5.8 && lat <= 6.2 && lng >= 116.0 && lng <= 116.3) {
      return 'Kota Kinabalu';
    } else if (lat >= 1.4 && lat <= 1.7 && lng >= 110.2 && lng <= 110.5) {
      return 'Kuching';
    } else {
      return 'Unknown City';
    }
  }

  /// Estimate state from coordinates (for Malaysia)
  static String _estimateStateFromCoordinates(double lat, double lng) {
    // Basic state estimation for Malaysia
    if (lat >= 3.0 && lat <= 3.3 && lng >= 101.5 && lng <= 101.8) {
      return 'Federal Territory';
    } else if (lat >= 5.2 && lat <= 5.6 && lng >= 100.1 && lng <= 100.5) {
      return 'Penang';
    } else if (lat >= 4.5 && lat <= 5.8 && lng >= 102.5 && lng <= 103.8) {
      return 'Terengganu';
    } else if (lat >= 1.2 && lat <= 2.8 && lng >= 103.0 && lng <= 104.5) {
      return 'Johor';
    } else if (lat >= 4.0 && lat <= 5.0 && lng >= 100.5 && lng <= 101.5) {
      return 'Perak';
    } else if (lat >= 2.5 && lat <= 3.8 && lng >= 101.0 && lng <= 102.0) {
      return 'Selangor';
    } else if (lat >= 4.0 && lat <= 7.5 && lng >= 115.0 && lng <= 119.5) {
      return 'Sabah';
    } else if (lat >= 0.8 && lat <= 5.0 && lng >= 109.5 && lng <= 115.5) {
      return 'Sarawak';
    } else {
      return 'Unknown State';
    }
  }

  /// Get default location
  static LocationData getDefaultLocation() {
    return _defaultLocation;
  }

  /// Check if coordinates are within Malaysia
  static bool isInMalaysia(double lat, double lng) {
    // Approximate bounds for Malaysia
    return lat >= 0.5 && lat <= 7.5 && lng >= 99.0 && lng <= 120.0;
  }
}