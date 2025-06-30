import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/app_theme.dart';
import '../models/weather_data.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  
  LocationService._();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log('Failed to check location service: $e');
      return false;
    }
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      developer.log('Failed to check location permission: $e');
      return LocationPermission.denied;
    }
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      developer.log('Failed to request location permission: $e');
      return LocationPermission.denied;
    }
  }

  // Get current position
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        developer.log('Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: AppConstants.locationTimeout,
      );

      developer.log('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      developer.log('Failed to get current position: $e');
      return null;
    }
  }

  // Get location stream for real-time tracking
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: AppConstants.locationTimeout,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Convert coordinates to address
  Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressParts = <String>[];
        
        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subAdministrativeArea != null && 
            placemark.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(placemark.subAdministrativeArea!);
        }
        if (placemark.administrativeArea != null && 
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }
        
        return addressParts.join(', ');
      }
    } catch (e) {
      developer.log('Failed to get address from coordinates: $e');
    }
    return null;
  }

  // Convert address to coordinates
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      developer.log('Failed to get coordinates from address: $e');
    }
    return null;
  }

  // Calculate distance between two points (in meters)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Calculate bearing between two points (in degrees)
  double calculateBearing({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.bearingBetween(lat1, lon1, lat2, lon2);
  }

  // Check if user is near a specific location
  bool isNearLocation({
    required Position currentPosition,
    required double targetLatitude,
    required double targetLongitude,
    double radiusInMeters = 500,
  }) {
    final distance = calculateDistance(
      lat1: currentPosition.latitude,
      lon1: currentPosition.longitude,
      lat2: targetLatitude,
      lon2: targetLongitude,
    );
    
    return distance <= radiusInMeters;
  }

  // Get current location as WeatherLocation
  Future<WeatherLocation?> getCurrentWeatherLocation({
    String? customName,
  }) async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      String locationName = customName ?? 'Vị trí hiện tại';
      String? address;

      // Try to get address
      if (customName == null) {
        address = await getAddressFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        if (address != null) {
          // Use first part of address as name
          final parts = address.split(', ');
          if (parts.isNotEmpty) {
            locationName = parts.first;
          }
        }
      }

      return WeatherLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: locationName,
        address: address,
      );
    } catch (e) {
      developer.log('Failed to get current weather location: $e');
      return null;
    }
  }

  // Check if two locations are close enough to be considered the same
  bool areLocationsNearby({
    required WeatherLocation location1,
    required WeatherLocation location2,
    double thresholdInMeters = 20000, // 20km default
  }) {
    final distance = calculateDistance(
      lat1: location1.latitude,
      lon1: location1.longitude,
      lat2: location2.latitude,
      lon2: location2.longitude,
    );
    
    return distance <= thresholdInMeters;
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${km.round()}km';
      }
    }
  }

  // Get location accuracy description
  String getAccuracyDescription(double accuracyInMeters) {
    if (accuracyInMeters <= 5) {
      return 'Rất chính xác';
    } else if (accuracyInMeters <= 20) {
      return 'Chính xác';
    } else if (accuracyInMeters <= 100) {
      return 'Khá chính xác';
    } else {
      return 'Ít chính xác';
    }
  }

  // Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      developer.log('Failed to open location settings: $e');
      return false;
    }
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      developer.log('Failed to open app settings: $e');
      return false;
    }
  }

  // Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      developer.log('Failed to get last known position: $e');
      return null;
    }
  }

  // Validate coordinates
  bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  // Get location permission status description
  String getPermissionStatusDescription(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Quyền truy cập vị trí bị từ chối';
      case LocationPermission.deniedForever:
        return 'Quyền truy cập vị trí bị từ chối vĩnh viễn';
      case LocationPermission.whileInUse:
        return 'Có quyền truy cập vị trí khi sử dụng app';
      case LocationPermission.always:
        return 'Có quyền truy cập vị trí luôn luôn';
      case LocationPermission.unableToDetermine:
        return 'Không thể xác định quyền truy cập vị trí';
    }
  }

  // Calculate estimated travel time (very basic estimation)
  Duration estimateTravelTime({
    required double distanceInMeters,
    double averageSpeedKmh = 30, // Default speed for city travel
  }) {
    final distanceInKm = distanceInMeters / 1000;
    final timeInHours = distanceInKm / averageSpeedKmh;
    final timeInMinutes = (timeInHours * 60).round();
    
    return Duration(minutes: timeInMinutes);
  }

  // Get compass direction from bearing
  String getCompassDirection(double bearing) {
    const directions = [
      'Bắc', 'Đông Bắc', 'Đông', 'Đông Nam',
      'Nam', 'Tây Nam', 'Tây', 'Tây Bắc'
    ];
    
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}
