# MapService - Flutter Map Rendering from JSON

This is a Flutter conversion of the JavaScript map rendering functionality. The `MapService` allows you to render Google Maps with markers, polylines, and routes from JSON configuration files.

## Features

- **JSON Configuration**: Load map settings from JSON files or API responses
- **GeoJSON Support**: Render GeoJSON layers with points, lines, and polygons
- **Road-Following Routes**: Use Google Directions API for road-following polylines
- **Custom Markers**: Support for custom marker icons and styling
- **Layer Management**: Multiple layer support with different rendering options
- **Error Handling**: Comprehensive error handling and loading states
- **Real-time Ready**: Placeholder for SignalR/WebSocket real-time updates

## Setup

### 1. Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.5.3
```

### 2. Google Maps API Key

The Google Maps API key is configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyAN397HAlCveqhw7idZNJHdhSidLl9rIKA" />
```

### 3. Install Dependencies

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../MapService.dart';

class MyMapScreen extends StatefulWidget {
  @override
  _MyMapScreenState createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadMapConfiguration();
  }

  Future<void> _loadMapConfiguration() async {
    // Your JSON configuration
    final jsonConfig = {
      "googleMapsApiKey": "YOUR_API_KEY",
      "initialCameraPosition": {
        "latitude": 6.9271,
        "longitude": 79.8612,
        "zoom": 12
      },
      "mapOptions": {
        "mapType": "normal",
        "zoomControlsEnabled": true
      },
      "layers": [
        {
          "id": "bus_stops",
          "type": "geojson",
          "sourceUrl": "https://your-api.com/bus-stops.geojson",
          "renderOptions": {
            "strokeColor": "#FF0000",
            "strokeWidth": 3,
            "followRoads": true
          }
        }
      ]
    };

    final result = await MapService.processMapConfiguration(jsonConfig);

    if (result.success) {
      setState(() {
        _initialCameraPosition = result.initialCameraPosition;
        _markers = result.markers;
        _polylines = result.polylines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        MapService.setMapController(controller);
      },
    );
  }
}
```

### JSON Configuration Format

```json
{
  "googleMapsApiKey": "YOUR_GOOGLE_MAPS_API_KEY",
  "initialCameraPosition": {
    "latitude": 6.9271,
    "longitude": 79.8612,
    "zoom": 12,
    "bearing": 0,
    "tilt": 0
  },
  "mapOptions": {
    "mapType": "normal",
    "zoomControlsEnabled": true,
    "compassEnabled": true,
    "myLocationButtonEnabled": true,
    "trafficEnabled": false,
    "indoorEnabled": true,
    "rotateGesturesEnabled": true,
    "scrollGesturesEnabled": true,
    "tiltGesturesEnabled": true,
    "zoomGesturesEnabled": true
  },
  "layers": [
    {
      "id": "layer_id",
      "type": "geojson",
      "sourceUrl": "https://your-api.com/data.geojson",
      "signalRHubUrl": "https://your-hub.com/busHub",
      "renderOptions": {
        "strokeColor": "#FF0000",
        "strokeWidth": 3,
        "strokeOpacity": 0.8,
        "followRoads": true,
        "clusterMarkers": false,
        "markerIconUrl": "https://your-cdn.com/icon.png",
        "animateMovement": false,
        "showLabel": true,
        "labelTemplate": "{name}",
        "labelOffset": [0, -10]
      }
    }
  ]
}
```

### Layer Types

#### 1. GeoJSON Layer

Renders GeoJSON data from a URL:

```json
{
  "id": "bus_stops",
  "type": "geojson",
  "sourceUrl": "https://your-api.com/bus-stops.geojson",
  "renderOptions": {
    "strokeColor": "#FF0000",
    "strokeWidth": 3,
    "followRoads": true
  }
}
```

#### 2. Realtime Layer

Placeholder for real-time updates (requires SignalR/WebSocket implementation):

```json
{
  "id": "live_buses",
  "type": "realtime",
  "signalRHubUrl": "https://your-hub.com/busHub",
  "renderOptions": {
    "markerIconUrl": "https://your-cdn.com/bus-icon.png"
  }
}
```

### Render Options

- **strokeColor**: Color of lines/polylines (hex or color name)
- **strokeWidth**: Width of lines in pixels
- **strokeOpacity**: Opacity of lines (0.0 to 1.0)
- **followRoads**: Whether to use Google Directions API for road-following routes
- **clusterMarkers**: Whether to cluster markers (not implemented yet)
- **markerIconUrl**: URL for custom marker icon
- **animateMovement**: Whether to animate marker movement
- **showLabel**: Whether to show labels on markers
- **labelTemplate**: Template for label text (e.g., "{name}")
- **labelOffset**: Offset for label position [x, y]

## API Reference

### MapService Class

#### Static Methods

- `processMapConfiguration(jsonResponse)`: Main method to process JSON configuration
- `setMapController(controller)`: Set the Google Maps controller reference
- `getMapController()`: Get the current map controller
- `clearMap()`: Clear all markers and polylines
- `addMarker(marker)`: Add a marker dynamically
- `removeMarker(markerId)`: Remove a marker by ID
- `addPolyline(polyline)`: Add a polyline dynamically
- `removePolyline(polylineId)`: Remove a polyline by ID

### Data Models

#### MapRenderResult
```dart
class MapRenderResult {
  final bool success;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final MapOptions mapOptions;
  final String? errorMessage;
}
```

#### MapConfiguration
```dart
class MapConfiguration {
  final String googleMapsApiKey;
  final InitialCameraPosition initialCameraPosition;
  final MapOptions mapOptions;
  final List<LayerConfiguration> layers;
}
```

#### LayerConfiguration
```dart
class LayerConfiguration {
  final String id;
  final String type;
  final String sourceUrl;
  final String? signalRHubUrl;
  final RenderOptions renderOptions;
}
```

## Example Implementation

See `lib/screens/map_example_screen.dart` for a complete example implementation.

## Road-Following Routes

The service supports road-following routes using Google Directions API:

1. Set `followRoads: true` in render options
2. The service will automatically use Google Directions API
3. Routes will follow actual roads instead of straight lines
4. Fallback to straight lines if Directions API fails

## Error Handling

The service includes comprehensive error handling:

- Network errors when fetching GeoJSON data
- Invalid JSON configuration
- Google Directions API failures
- Missing or invalid coordinates
- Loading states and retry functionality

## Customization

### Custom Marker Icons

```dart
// In your layer configuration
"renderOptions": {
  "markerIconUrl": "https://your-cdn.com/custom-icon.png"
}
```

### Custom Colors

```dart
// Hex colors
"strokeColor": "#FF0000"

// Color names
"strokeColor": "red"
```

### Map Styles

```json
"mapOptions": {
  "styles": [
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    }
  ]
}
```

## Performance Considerations

- Use `followRoads: false` for better performance with many routes
- Implement marker clustering for large datasets
- Consider caching GeoJSON data locally
- Use appropriate zoom levels for data density

## Troubleshooting

### Common Issues

1. **Map not loading**: Check Google Maps API key and permissions
2. **No markers/polylines**: Verify GeoJSON URL and format
3. **Road-following not working**: Check Directions API quota and billing
4. **Network errors**: Verify internet connection and URL accessibility

### Debug Information

The service provides detailed console output for debugging:

```
Layer bus_stops: Rendered 15 markers and processed 3 routes
Processing 3 routes to follow roads. This may take a moment...
```

## Next Steps

1. **Real-time Implementation**: Add SignalR/WebSocket support for live updates
2. **Marker Clustering**: Implement marker clustering for large datasets
3. **Offline Support**: Add offline map caching and data persistence
4. **Custom Overlays**: Support for custom map overlays and tiles
5. **Performance Optimization**: Implement lazy loading and viewport-based rendering

## Dependencies

- `google_maps_flutter: ^2.5.3`: Google Maps integration
- `http: ^0.13.3`: HTTP requests for GeoJSON data

## Permissions

Make sure to add the following permissions to your Android manifest:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

This MapService provides a powerful and flexible way to render maps from JSON configuration, making it easy to integrate with your existing APIs and data sources. 