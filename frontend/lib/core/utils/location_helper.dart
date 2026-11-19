import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationAccessException implements Exception {
  final String message;
  final bool openAppSettings;
  final bool openLocationSettings;

  const LocationAccessException(
    this.message, {
    this.openAppSettings = false,
    this.openLocationSettings = false,
  });

  bool get canOpenSettings => openAppSettings || openLocationSettings;

  @override
  String toString() => message;
}

class LocationHelper {
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        (latitude != 0 || longitude != 0);
  }

  /// Fetches the current position of the user.
  /// Handles permission checks and service status checks.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationAccessException(
        'Location services are off. Turn on GPS and try again.',
        openLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationAccessException(
          'Location permission was denied. Allow it in app settings or choose a location on the map.',
          openAppSettings: true,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationAccessException(
        'Location permission is blocked. Allow it in app settings or choose a location on the map.',
        openAppSettings: true,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
    } on TimeoutException {
      throw const LocationAccessException(
        'Could not get a GPS fix. Check your signal and try again.',
      );
    } on LocationServiceDisabledException {
      throw const LocationAccessException(
        'Location services are off. Turn on GPS and try again.',
        openLocationSettings: true,
      );
    } on PermissionDeniedException {
      throw const LocationAccessException(
        'Location permission is unavailable. Allow it in app settings or choose a location on the map.',
        openAppSettings: true,
      );
    }
  }

  static Future<bool> openSettings(LocationAccessException error) {
    if (error.openLocationSettings) {
      return Geolocator.openLocationSettings();
    }
    if (error.openAppSettings) {
      return Geolocator.openAppSettings();
    }
    return Future.value(false);
  }
}
