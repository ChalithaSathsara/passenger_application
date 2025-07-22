import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class LiveMapService {
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
        {"featureType": "poi", "stylers": [{"visibility": "off"}]},
        {"featureType": "transit", "stylers": [{"visibility": "off"}]},
        {"featureType": "road.highway", "elementType": "labels", "stylers": [{"visibility": "off"}]}
      ]
    },
    "layers": [
      {
        "id": "busStopsLayer",
        "type": "geojson",
        "sourceUrl": "https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson",
        "renderOptions": {
          "markerIconUrl": "https://placehold.co/32x32/FF0000/FFFFFF?text=ST",
          "clusterMarkers": true
        }
      },
      {
        "id": "passengerLayer",
        "type": "realtime",
        // No signalRHubUrl, just update marker directly
        "renderOptions": {
          "markerIconUrl": "https://placehold.co/32x32/000000/FFFFFF?text=ME",
          "animateMovement": true,
          "showLabel": true,
          "labelTemplate": "{passengerName}",
          "labelOffset": [0, -35]
        }
      },
      {
        "id": "famousPlacesLayer",
        "type": "geojson",
        "sourceUrl": "https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/famousplaces/geojson",
        "renderOptions": {
          "markerIconUrl": "https://placehold.co/32x32/0000FF/FFFFFF?text=FP",
          "clusterMarkers": true
        }
      },
      {
        "id": "singleBusRouteLayer",
        "type": "realtime",
        "signalRHubUrl": "https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/busHub",
        "renderOptions": {
          "strokeColor": "#FF0000",
          "strokeWidth": 3,
          "strokeOpacity": 0.8
        }
      }
    ]
  };

  static Set<Marker> _markers = {};
  static Set<Marker> _busStopMarkers = {};
  static Set<Marker> _famousPlaceMarkers = {};
  static Set<Polyline> _busRoutePolylines = {};
  static Marker? _passengerMarker;
  static BitmapDescriptor? _orangeDotIcon;
  static BitmapDescriptor? _blueBoxIcon;
  static BitmapDescriptor? _redDotIcon;

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

  // Helper to generate a small dark blue box as a BitmapDescriptor
  static Future<BitmapDescriptor> getBlueBoxIcon() async {
    if (_blueBoxIcon != null) return _blueBoxIcon!;

    final double size = 32.0;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = const Color(0xFF00008B); // Dark blue

    // Draw a filled square
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List bytes = byteData!.buffer.asUint8List();
    _blueBoxIcon = BitmapDescriptor.fromBytes(bytes);

    return _blueBoxIcon!;
  }

  /// Helper to load the small red dot icon for favorite places
  static Future<BitmapDescriptor> getRedDotIcon() async {
    if (_redDotIcon != null) return _redDotIcon!;
    const double size = 32.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    final image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    _redDotIcon = BitmapDescriptor.fromBytes(bytes);
    return _redDotIcon!;
  }

  static Map<String, dynamic> getMapConfig() {
    return staticMapConfig;
  }

  static Future<void> updatePassengerLocation({
    required String passengerId,
    required double latitude,
    required double longitude,
    String? passengerName,
  }) async {
    _passengerMarker = Marker(
      markerId: MarkerId('passenger_$passengerId'),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: passengerName ?? 'ME'),
    );
  }

  static Future<void> fetchAndAddBusStopMarkers() async {
    const geoJsonUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson';
    try {
      final response = await http.get(Uri.parse(geoJsonUrl));
      if (response.statusCode != 200) return;
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is List) {
        final features = geoJson['features'] as List;
        _busStopMarkers.clear();
        final orangeDotIcon = await _getOrangeDotIcon();
        for (final feature in features) {
          if (feature['geometry']?['type'] == 'Point' && feature['geometry']?['coordinates'] is List && feature['properties'] != null) {
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

  static Future<void> fetchAndAddFamousPlaceMarkers() async {
    const geoJsonUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/famousplaces/geojson';
    try {
      final response = await http.get(Uri.parse(geoJsonUrl));
      if (response.statusCode != 200) return;
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is List) {
        final features = geoJson['features'] as List;
        _famousPlaceMarkers.clear();
        for (final feature in features) {
          if (feature['geometry']?['type'] == 'Point' && feature['geometry']?['coordinates'] is List && feature['properties'] != null) {
            final coords = feature['geometry']['coordinates'];
            final lat = coords[1];
            final lng = coords[0];
            final name = feature['properties']['name'] ?? 'Famous Place';
            _famousPlaceMarkers.add(
              Marker(
                markerId: MarkerId('famousplace_${name}_$lat$lng'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(title: name),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching famous places GeoJSON: $e');
    }
  }

  static Future<void> fetchAndAddBusRoutePolyline() async {
    const geoJsonUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busroute/single/geojson/174';
    try {
      final response = await http.get(Uri.parse(geoJsonUrl));
      if (response.statusCode != 200) return;
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is List) {
        final features = geoJson['features'] as List;
        _busRoutePolylines.clear();
        for (final feature in features) {
          if (feature['geometry']?['type'] == 'LineString' && feature['geometry']?['coordinates'] is List) {
            final coords = feature['geometry']['coordinates'] as List;
            final points = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
            _busRoutePolylines.add(
              Polyline(
                polylineId: PolylineId('busroute_174'),
                points: points,
                color: Colors.red,
                width: 3,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching bus route GeoJSON: $e');
    }
  }

  static Future<Polyline?> fetchBusRoutePolylineFromGeoJsonUrl(String url, {String polylineId = 'selected_route'}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is List && geoJson['features'].isNotEmpty) {
        final feature = geoJson['features'][0];
        if (feature['geometry']?['type'] == 'LineString' && feature['geometry']?['coordinates'] is List) {
          final coords = feature['geometry']['coordinates'] as List;
          final points = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
          // The polyline follows the road as per the GeoJSON LineString, not a straight line
          return Polyline(
            polylineId: PolylineId(polylineId),
            points: points,
            color: Colors.red, // Use a strong color for visibility
            width: 5,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching route GeoJSON: $e');
      return null;
    }
  }

  static Future<Polyline?> fetchDirectionsPolyline({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
    String polylineId = 'directions_route',
  }) async {
    try {
      final apiKey = staticMapConfig['googleMapsApiKey'];
      final startStr = '${start.latitude},${start.longitude}';
      final endStr = '${end.latitude},${end.longitude}';
      String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$startStr&destination=$endStr&key=$apiKey';
      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointsStr = waypoints.map((w) => '${w.latitude},${w.longitude}').join('|');
        url += '&waypoints=$waypointsStr';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        debugPrint('Directions API failed: ${response.body}');
        return null;
      }
      final data = jsonDecode(response.body);
      if (data['routes'] == null || data['routes'].isEmpty) {
        debugPrint('No routes found in Directions API response');
        return null;
      }
      final overviewPolyline = data['routes'][0]['overview_polyline']['points'];
      final points = _decodePolyline(overviewPolyline);
      return Polyline(
        polylineId: PolylineId(polylineId),
        points: points,
        color: Colors.blue,
        width: 6,
      );
    } catch (e) {
      debugPrint('Error fetching directions polyline: $e');
      return null;
    }
  }

  // Polyline decoding helper
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  static Set<Marker> getMarkers() {
    final all = <Marker>{};
    if (_passengerMarker != null) all.add(_passengerMarker!);
    all.addAll(_busStopMarkers);
    all.addAll(_famousPlaceMarkers);
    return all;
  }

  static Set<Polyline> getPolylines() {
    return _busRoutePolylines;
  }

  static void clearMarkers() {
    _markers.clear();
    _busStopMarkers.clear();
    _famousPlaceMarkers.clear();
    _busRoutePolylines.clear();
    _passengerMarker = null;
  }
} 