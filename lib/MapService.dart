import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapService {
  static GoogleMapController? _mapController;
  static Set<Marker> _markers = {};
  static Set<Polyline> _polylines = {};
  static MapConfiguration? _config;

  /// Main function to process map configuration and return map data
  static Future<MapRenderResult> processMapConfiguration(
    Map<String, dynamic> jsonResponse,
  ) async {
    try {
      _config = MapConfiguration.fromJson(jsonResponse);

      // Clear previous data
      _markers.clear();
      _polylines.clear();

      // Get initial camera position
      final initialCamera = CameraPosition(
        target: LatLng(
          _config!.initialCameraPosition.latitude,
          _config!.initialCameraPosition.longitude,
        ),
        zoom: _config!.initialCameraPosition.zoom,
        bearing: _config!.initialCameraPosition.bearing,
        tilt: _config!.initialCameraPosition.tilt,
      );

      // Process layers
      await _processLayers(_config!.layers);

      return MapRenderResult(
        success: true,
        initialCameraPosition: initialCamera,
        markers: Set.from(_markers),
        polylines: Set.from(_polylines),
        mapOptions: _config!.mapOptions,
        errorMessage: null,
      );
    } catch (e) {
      return MapRenderResult(
        success: false,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 1,
        ),
        markers: {},
        polylines: {},
        mapOptions: MapOptions.defaultOptions(),
        errorMessage: 'Error processing map configuration: $e',
      );
    }
  }

  /// Process all layers in the configuration
  static Future<void> _processLayers(List<LayerConfiguration> layers) async {
    for (final layer in layers) {
      try {
        switch (layer.type) {
          case 'geojson':
            await _processGeoJsonLayer(layer);
            break;
          case 'realtime':
            await _processRealtimeLayer(layer);
            break;
          default:
            print('Unknown layer type: ${layer.type}');
        }
      } catch (e) {
        print('Error processing layer ${layer.id}: $e');
      }
    }
  }

  /// Process GeoJSON layer
  static Future<void> _processGeoJsonLayer(LayerConfiguration layer) async {
    try {
      final response = await http.get(Uri.parse(layer.sourceUrl));

      if (response.statusCode == 200) {
        final geoJsonData = json.decode(response.body);

        if (geoJsonData['features'] != null) {
          final features = geoJsonData['features'] as List;
          final markers = <Marker>[];
          int routeCount = 0;

          for (int i = 0; i < features.length; i++) {
            final feature = features[i];
            final geometry = feature['geometry'];
            final properties = feature['properties'] ?? {};

            if (geometry != null && geometry['coordinates'] != null) {
              final geometryType = geometry['type'];
              final coordinates = geometry['coordinates'];

              if (geometryType == 'Point') {
                final marker = await _createPointMarker(
                  coordinates,
                  properties,
                  layer,
                  i,
                );
                markers.add(marker);
              } else if (geometryType == 'LineString') {
                await _createLineStringRoute(
                  coordinates,
                  properties,
                  layer,
                  i,
                  routeCount,
                );
                routeCount++;
              } else if (geometryType == 'MultiLineString') {
                for (final lineCoords in coordinates) {
                  await _createLineStringRoute(
                    lineCoords,
                    properties,
                    layer,
                    i,
                    routeCount,
                  );
                  routeCount++;
                }
              }
            }
          }

          // Add all markers
          _markers.addAll(markers);

          print(
            'Layer ${layer.id}: Rendered ${markers.length} markers and processed $routeCount routes',
          );

          if (routeCount > 0) {
            print(
              'Processing $routeCount routes to follow roads. This may take a moment...',
            );
          }
        } else {
          print(
            'GeoJSON data for ${layer.id} does not contain a \'features\' array.',
          );
        }
      } else {
        print(
          'HTTP error! status: ${response.statusCode} for ${layer.sourceUrl}',
        );
      }
    } catch (e) {
      print('Error processing GeoJSON layer ${layer.id}: $e');
    }
  }

  /// Process realtime layer (placeholder for SignalR or WebSocket implementation)
  static Future<void> _processRealtimeLayer(LayerConfiguration layer) async {
    // This would typically connect to SignalR hub or WebSocket
    print(
      'Realtime layer ${layer.id} requires SignalR/WebSocket implementation',
    );
    print('Hub URL: ${layer.signalRHubUrl}');

    // For now, you can add static markers or implement your real-time logic here
    // Example: Add a sample marker for realtime layer
    if (layer.renderOptions.markerIconUrl != null) {
      final icon = await _createMarkerIcon(layer.renderOptions.markerIconUrl!);
      final marker = Marker(
        markerId: MarkerId('${layer.id}_realtime_sample'),
        position: const LatLng(6.9271, 79.8612), // Sample position
        icon: icon,
        infoWindow: const InfoWindow(
          title: 'Realtime Marker',
          snippet: 'Sample realtime marker',
        ),
      );
      _markers.add(marker);
    }
  }

  /// Create point marker
  static Future<Marker> _createPointMarker(
    List coordinates,
    Map<String, dynamic> properties,
    LayerConfiguration layer,
    int index,
  ) async {
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

    if (layer.renderOptions.markerIconUrl != null) {
      icon = await _createMarkerIcon(layer.renderOptions.markerIconUrl!);
    }

    return Marker(
      markerId: MarkerId('${layer.id}marker$index'),
      position: LatLng(coordinates[1], coordinates[0]),
      icon: icon,
      infoWindow: InfoWindow(
        title: properties['name'] ?? 'Point ${index + 1}',
        snippet: properties['description'] ?? '',
      ),
    );
  }

  /// Create line string route (road-following or straight line)
  static Future<void> _createLineStringRoute(
    List coordinates,
    Map<String, dynamic> properties,
    LayerConfiguration layer,
    int index,
    int routeCount,
  ) async {
    if (coordinates.length < 2) return;

    // Add delay to avoid rate limiting for road-following routes
    if (layer.renderOptions.followRoads != false) {
      await Future.delayed(Duration(milliseconds: routeCount * 100));
      await _createRoadFollowingRoute(coordinates, properties, layer, index);
    } else {
      _createStraightLineRoute(coordinates, properties, layer, index);
    }
  }

  /// Create road-following route using Directions API
  static Future<void> _createRoadFollowingRoute(
    List coordinates,
    Map<String, dynamic> properties,
    LayerConfiguration layer,
    int index,
  ) async {
    try {
      // Convert coordinates to waypoints for Directions API
      final waypoints = coordinates
          .skip(1)
          .take(coordinates.length - 2)
          .map((coord) => '${coord[1]},${coord[0]}')
          .join('|');

      final origin = '${coordinates.first[1]},${coordinates.first[0]}';
      final destination = '${coordinates.last[1]},${coordinates.last[0]}';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '&waypoints=$waypoints'
        '&key=${_config!.googleMapsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final path = <LatLng>[];

          // Extract path from directions result
          for (final leg in route['legs']) {
            for (final step in leg['steps']) {
              final polyline = step['polyline'];
              if (polyline != null && polyline['points'] != null) {
                final decodedPoints = _decodePolyline(polyline['points']);
                path.addAll(decodedPoints);
              }
            }
          }

          final polyline = Polyline(
            polylineId: PolylineId('${layer.id}road_route$index'),
            points: path,
            color: _parseColor(layer.renderOptions.strokeColor) ?? Colors.red,
            width: layer.renderOptions.strokeWidth ?? 3,
            geodesic: false, // False since we're following roads
          );

          _polylines.add(polyline);
        } else {
          print('Directions request failed: ${data['status']}');
          // Fall back to straight-line polyline
          _createStraightLineRoute(coordinates, properties, layer, index);
        }
      } else {
        print('HTTP error for directions request: ${response.statusCode}');
        _createStraightLineRoute(coordinates, properties, layer, index);
      }
    } catch (e) {
      print('Error creating road-following route: $e');
      _createStraightLineRoute(coordinates, properties, layer, index);
    }
  }

  /// Create straight-line route (fallback)
  static void _createStraightLineRoute(
    List coordinates,
    Map<String, dynamic> properties,
    LayerConfiguration layer,
    int index,
  ) {
    final points = coordinates
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();

    final polyline = Polyline(
      polylineId: PolylineId('${layer.id}straight_route$index'),
      points: points,
      color: _parseColor(layer.renderOptions.strokeColor) ?? Colors.red,
      width: layer.renderOptions.strokeWidth ?? 2,
      geodesic: true,
      patterns: [PatternItem.dash(10), PatternItem.gap(5)], // Dashed line
    );

    _polylines.add(polyline);
  }

  /// Decode Google's polyline encoding
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

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  /// Create custom marker icon from URL
  static Future<BitmapDescriptor> _createMarkerIcon(String iconUrl) async {
    try {
      // For network images, you might want to use a different approach
      // This is a placeholder implementation
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } catch (e) {
      print('Error creating marker icon: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Parse color string to Color object
  static Color? _parseColor(String? colorString) {
    if (colorString == null) return null;

    // Handle hex colors like #FF0000
    if (colorString.startsWith('#')) {
      final hex = colorString.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    // Handle common color names
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return null;
    }
  }

  /// Get MapType from string
  static MapType _getMapType(String? mapTypeString) {
    switch (mapTypeString?.toLowerCase()) {
      case 'satellite':
        return MapType.satellite;
      case 'hybrid':
        return MapType.hybrid;
      case 'terrain':
        return MapType.terrain;
      case 'roadmap':
      case 'normal':
        return MapType.normal;
      default:
        return MapType.normal;
    }
  }

  /// Set map controller reference
  static void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Get current map controller
  static GoogleMapController? getMapController() {
    return _mapController;
  }

  /// Clear all markers and polylines
  static void clearMap() {
    _markers.clear();
    _polylines.clear();
  }

  /// Add marker dynamically
  static void addMarker(Marker marker) {
    _markers.add(marker);
  }

  /// Remove marker
  static void removeMarker(String markerId) {
    _markers.removeWhere((marker) => marker.markerId.value == markerId);
  }

  /// Add polyline dynamically
  static void addPolyline(Polyline polyline) {
    _polylines.add(polyline);
  }

  /// Remove polyline
  static void removePolyline(String polylineId) {
    _polylines.removeWhere(
      (polyline) => polyline.polylineId.value == polylineId,
    );
  }
}

/// Result class for map rendering
class MapRenderResult {
  final bool success;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final MapOptions mapOptions;
  final String? errorMessage;

  MapRenderResult({
    required this.success,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.mapOptions,
    this.errorMessage,
  });
}

/// Data model classes
class MapConfiguration {
  final String googleMapsApiKey;
  final InitialCameraPosition initialCameraPosition;
  final MapOptions mapOptions;
  final List<LayerConfiguration> layers;

  MapConfiguration({
    required this.googleMapsApiKey,
    required this.initialCameraPosition,
    required this.mapOptions,
    required this.layers,
  });

  factory MapConfiguration.fromJson(Map<String, dynamic> json) {
    return MapConfiguration(
      googleMapsApiKey: json['googleMapsApiKey'] ?? '',
      initialCameraPosition: InitialCameraPosition.fromJson(
        json['initialCameraPosition'],
      ),
      mapOptions: MapOptions.fromJson(json['mapOptions']),
      layers: (json['layers'] as List)
          .map((layer) => LayerConfiguration.fromJson(layer))
          .toList(),
    );
  }
}

class InitialCameraPosition {
  final double latitude;
  final double longitude;
  final double zoom;
  final double bearing;
  final double tilt;

  InitialCameraPosition({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    this.bearing = 0,
    this.tilt = 0,
  });

  factory InitialCameraPosition.fromJson(Map<String, dynamic> json) {
    return InitialCameraPosition(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      zoom: json['zoom'].toDouble(),
      bearing: json['bearing']?.toDouble() ?? 0,
      tilt: json['tilt']?.toDouble() ?? 0,
    );
  }
}

class MapOptions {
  final String mapType;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final bool myLocationButtonEnabled;
  final bool trafficEnabled;
  final bool indoorEnabled;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool zoomGesturesEnabled;
  final List<MapStyle>? styles;

  MapOptions({
    required this.mapType,
    required this.zoomControlsEnabled,
    required this.compassEnabled,
    required this.myLocationButtonEnabled,
    required this.trafficEnabled,
    required this.indoorEnabled,
    required this.rotateGesturesEnabled,
    required this.scrollGesturesEnabled,
    required this.tiltGesturesEnabled,
    required this.zoomGesturesEnabled,
    this.styles,
  });

  factory MapOptions.fromJson(Map<String, dynamic> json) {
    return MapOptions(
      mapType: json['mapType'] ?? 'normal',
      zoomControlsEnabled: json['zoomControlsEnabled'] ?? true,
      compassEnabled: json['compassEnabled'] ?? true,
      myLocationButtonEnabled: json['myLocationButtonEnabled'] ?? false,
      trafficEnabled: json['trafficEnabled'] ?? false,
      indoorEnabled: json['indoorEnabled'] ?? true,
      rotateGesturesEnabled: json['rotateGesturesEnabled'] ?? true,
      scrollGesturesEnabled: json['scrollGesturesEnabled'] ?? true,
      tiltGesturesEnabled: json['tiltGesturesEnabled'] ?? true,
      zoomGesturesEnabled: json['zoomGesturesEnabled'] ?? true,
      styles: json['styles'] != null
          ? (json['styles'] as List)
                .map((style) => MapStyle.fromJson(style))
                .toList()
          : null,
    );
  }

  factory MapOptions.defaultOptions() {
    return MapOptions(
      mapType: 'normal',
      zoomControlsEnabled: true,
      compassEnabled: true,
      myLocationButtonEnabled: false,
      trafficEnabled: false,
      indoorEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }
}

class MapStyle {
  final String? featureType;
  final String? elementType;
  final List<Map<String, dynamic>> stylers;

  MapStyle({this.featureType, this.elementType, required this.stylers});

  factory MapStyle.fromJson(Map<String, dynamic> json) {
    return MapStyle(
      featureType: json['featureType'],
      elementType: json['elementType'],
      stylers: List<Map<String, dynamic>>.from(json['stylers'] ?? []),
    );
  }
}

class LayerConfiguration {
  final String id;
  final String type;
  final String sourceUrl;
  final String? signalRHubUrl;
  final RenderOptions renderOptions;

  LayerConfiguration({
    required this.id,
    required this.type,
    required this.sourceUrl,
    this.signalRHubUrl,
    required this.renderOptions,
  });

  factory LayerConfiguration.fromJson(Map<String, dynamic> json) {
    return LayerConfiguration(
      id: json['id'],
      type: json['type'],
      sourceUrl: json['sourceUrl'] ?? '',
      signalRHubUrl: json['signalRHubUrl'],
      renderOptions: RenderOptions.fromJson(json['renderOptions'] ?? {}),
    );
  }
}

class RenderOptions {
  final String? strokeColor;
  final int? strokeWidth;
  final double? strokeOpacity;
  final bool? followRoads;
  final bool? clusterMarkers;
  final String? markerIconUrl;
  final bool? animateMovement;
  final bool? showLabel;
  final String? labelTemplate;
  final List<double>? labelOffset;

  RenderOptions({
    this.strokeColor,
    this.strokeWidth,
    this.strokeOpacity,
    this.followRoads,
    this.clusterMarkers,
    this.markerIconUrl,
    this.animateMovement,
    this.showLabel,
    this.labelTemplate,
    this.labelOffset,
  });

  factory RenderOptions.fromJson(Map<String, dynamic> json) {
    return RenderOptions(
      strokeColor: json['strokeColor'],
      strokeWidth: json['strokeWidth'],
      strokeOpacity: json['strokeOpacity']?.toDouble(),
      followRoads: json['followRoads'],
      clusterMarkers: json['clusterMarkers'],
      markerIconUrl: json['markerIconUrl'],
      animateMovement: json['animateMovement'],
      showLabel: json['showLabel'],
      labelTemplate: json['labelTemplate'],
      labelOffset: json['labelOffset']?.cast<double>(),
    );
  }
}
