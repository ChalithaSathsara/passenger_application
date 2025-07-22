import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;

class TripPlannerMapService {
  static final Map<String, dynamic> staticMapConfig = {
    "googleMapsApiKey": "AIzaSyAN397HAlCveqhw7idZNJHdhSidLl9rIKA",
    "initialCameraPosition": {
      "latitude": 6.9271,
      "longitude": 79.8612,
      "zoom": 12,
      "bearing": 0,
      "tilt": 0
    },
    "mapOptions": {
      "mapType": "roadmap",
      "zoomControlsEnabled": true,
      "compassEnabled": true,
      "myLocationButtonEnabled": true,
      "trafficEnabled": true,
      "indoorEnabled": false,
      "rotateGesturesEnabled": true,
      "scrollGesturesEnabled": true,
      "tiltGesturesEnabled": true,
      "zoomGesturesEnabled": true,
      "styles": [
        {
          "featureType": "poi",
          "stylers": [
            {"visibility": "off"}
          ]
        },
        {
          "featureType": "transit",
          "stylers": [
            {"visibility": "off"}
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels",
          "stylers": [
            {"visibility": "off"}
          ]
        }
      ]
    },
    "layers": [
      {
        "id": "passengerLayer",
        "type": "realtime",
        // No signalRHubUrl, we will update marker directly
        "renderOptions": {
          "markerIconUrl": "https://placehold.co/32x32/000000/FFFFFF?text=ME",
          "animateMovement": true,
          "showLabel": true,
          "labelTemplate": "{passengerName}",
          "labelOffset": [0, -35]
        }
      },
      {
        "id": "busStopsLayer",
        "type": "geojson",
        "sourceUrl": "https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson",
        "renderOptions": {
          "markerIconUrl": "https://placehold.co/32x32/FFA500/FFFFFF?text=ST", // Orange marker
          "clusterMarkers": true
        }
      }
    ]
  };

  static Set<Marker> _markers = {};
  static Set<Marker> _busStopMarkers = {};
  static BitmapDescriptor? _orangeDotIcon;

  /// Helper to load the small orange dot icon
  static Future<BitmapDescriptor> _getOrangeDotIcon() async {
    if (_orangeDotIcon != null) return _orangeDotIcon!;
    
    const double size = 32.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.orange;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    _orangeDotIcon = BitmapDescriptor.fromBytes(bytes);
    return _orangeDotIcon!;
  }

  static Map<String, dynamic> getMapConfig() {
    return staticMapConfig;
  }

  static void updatePassengerLocation({
    required String passengerId,
    required double latitude,
    required double longitude,
    String? passengerName,
  }) {
    final markerId = MarkerId('passenger_$passengerId');
    _markers.removeWhere((m) => m.markerId == markerId);
    _markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'ME'),
      ),
    );
  }

  /// Fetches bus stops from GeoJSON and adds them as orange markers
  static Future<void> fetchAndAddBusStopMarkers() async {
    const geoJsonUrl =
        'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson';
    try {
      final response = await http.get(Uri.parse(geoJsonUrl));
      if (response.statusCode != 200) {
        debugPrint('Failed to fetch bus stop GeoJSON: ${response.statusCode}');
        return;
      }
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is List) {
        final features = geoJson['features'] as List;
        _busStopMarkers.clear();
        final orangeDotIcon = await _getOrangeDotIcon();
        for (final feature in features) {
          if (feature['geometry']?['type'] == 'Point' &&
              feature['geometry']?['coordinates'] is List &&
              feature['properties'] != null) {
            final coords = feature['geometry']['coordinates'];
            final lat = coords[1];
            final lng = coords[0];
            final name = feature['properties']['name'] ?? 'Bus Stop';
            _busStopMarkers.add(
              Marker(
                markerId: MarkerId('busstop_${name}_$lat$lng'),
                position: LatLng(lat, lng),
                icon: orangeDotIcon,
                infoWindow: InfoWindow(title: name),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching bus stop GeoJSON: $e');
    }
  }

  /// Returns all markers (passenger + bus stops)
  static Set<Marker> getMarkers() {
    return Set.from(_markers)..addAll(_busStopMarkers);
  }

  static void clearMarkers() {
    _markers.clear();
    _busStopMarkers.clear();
  }
} 