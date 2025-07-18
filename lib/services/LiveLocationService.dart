import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationService {
  static LiveLocationService? _instance;
  static LiveLocationService get instance =>
      _instance ??= LiveLocationService._();

  LiveLocationService._();

  // Live location data
  Map<String, dynamic>? _currentPassengerLocation;

  // Map controllers and data
  GoogleMapController? _mapController;
  Set<Marker> _liveMarkers = {};

  // Stream controllers for real-time updates
  final StreamController<Map<String, dynamic>> _passengerLocationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Set<Marker>> _markersController =
      StreamController<Set<Marker>>.broadcast();

  // Streams for UI updates
  Stream<Map<String, dynamic>> get passengerLocationStream =>
      _passengerLocationController.stream;
  Stream<Set<Marker>> get markersStream => _markersController.stream;

  // Current data getters
  Map<String, dynamic>? get currentPassengerLocation =>
      _currentPassengerLocation;
  Set<Marker> get liveMarkers => Set.from(_liveMarkers);

  /// Set the map controller for camera movements
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Process SignalR message for live location updates
  void processSignalRMessage(String methodName, List<dynamic> arguments) {
    try {
      print('=== LIVE LOCATION SERVICE ===');
      print('Processing method: $methodName');
      print('Arguments: $arguments');

      switch (methodName) {
        case 'BusLocationUpdated':
          print('Handling BusLocationUpdated method');
          _handleLocationUpdate(arguments);
          break;
        case 'connection_confirmed':
          print('LiveLocationService: SignalR connection confirmed');
          break;
        default:
          print('LiveLocationService: Unknown method: $methodName');
      }
      print('=== END LIVE LOCATION SERVICE ===');
    } catch (e) {
      print('LiveLocationService: Error processing message: $e');
    }
  }

  /// Handle location updates from SignalR
  void _handleLocationUpdate(List<dynamic> arguments) {
    try {
      print('Handling location update with ${arguments.length} arguments');

      if (arguments.length >= 3) {
        final busId = arguments[0] as String;
        final latitude = arguments[1] as double;
        final longitude = arguments[2] as double;

        print(
          'Extracted location: BusID=$busId, Lat=$latitude, Lng=$longitude',
        );

        final locationData = {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'busId': busId,
        };

        _currentPassengerLocation = locationData;
        _passengerLocationController.add(locationData);

        print('Location data sent to stream');

        // Update passenger marker on map
        _updatePassengerMarker(locationData);

        print('LiveLocationService: Location updated: $latitude, $longitude');
      } else {
        print('Invalid arguments length: ${arguments.length} (expected 3)');
      }
    } catch (e) {
      print('LiveLocationService: Error handling location update: $e');
      print('Error details: ${e.toString()}');
    }
  }

  /// Update passenger marker on map
  void _updatePassengerMarker(Map<String, dynamic> locationData) async {
    try {
      // Remove existing passenger marker
      _liveMarkers.removeWhere(
        (marker) => marker.markerId.value.startsWith('passenger_'),
      );

      // Create new passenger marker
      final marker = Marker(
        markerId: const MarkerId('passenger_current'),
        position: LatLng(locationData['latitude'], locationData['longitude']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Updated: ${DateTime.now().toString().substring(11, 19)}',
        ),
      );

      _liveMarkers.add(marker);
      _markersController.add(Set.from(_liveMarkers));

      // Move camera to passenger location if it's the first update
      if (_mapController != null && _currentPassengerLocation == null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locationData['latitude'], locationData['longitude']),
            15.0,
          ),
        );
      }
    } catch (e) {
      print('LiveLocationService: Error updating passenger marker: $e');
    }
  }

  /// Clear all live data
  void clearLiveData() {
    _currentPassengerLocation = null;
    _liveMarkers.clear();

    _passengerLocationController.add({});
    _markersController.add({});
  }

  /// Dispose of resources
  void dispose() {
    _passengerLocationController.close();
    _markersController.close();
  }
}
