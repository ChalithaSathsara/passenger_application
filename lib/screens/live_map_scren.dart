import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http.get
import '../map_service_live_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../signalr_connection.dart';
// Remove TripPlanStorage and all persistence logic
// Only use widget.startLocation, widget.destinationLocation, and widget.routeStops
// Remove _saveTripData, _loadTripData, and all listeners related to saving
// Remove any import of trip_plan_storage_helper.dart
// Remove any code that references TripPlanStorage
// Remove any code that loads or saves trip data from storage
// The screen should only use the arguments passed to it

// class LiveMapScreen extends StatefulWidget {
//   final String passengerId;
//   final String? startLocation;
//   final String? destinationLocation;
//   final CameraPosition? cameraPosition;
//   final String? busRouteGeoJsonUrl;
//   final List<dynamic>? routeStops;
//   final String? selectedBusNumberPlate; // Added for filtering bus updates

//   const LiveMapScreen({
//     Key? key,
//     required this.passengerId,
//     this.startLocation,
//     this.destinationLocation,
//     this.cameraPosition,
//     this.busRouteGeoJsonUrl,
//     this.routeStops,
//     this.selectedBusNumberPlate, // Added for filtering bus updates
//   }) : super(key: key);

//   @override
//   State<LiveMapScreen> createState() => _LiveMapScreenState();
// }

// class _LiveMapScreenState extends State<LiveMapScreen> {
//   int _selectedIndex = 2;
//   bool isSwapped = false;
//   final TextEditingController _startController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   // Removed SignalR, MapService, and map state fields
//   CameraPosition _initialCameraPosition = const CameraPosition(
//     target: LatLng(6.9271, 79.8612),
//     zoom: 12.0,
//   );
//   bool _isMapInteracting = false;
//   bool _isLoadingMap = false;
//   String? _mapErrorMessage;
//   GoogleMapController? _mapController;
//   Set<Marker> _mapMarkers = {};
//   Set<Polyline> _mapPolylines = {};
//   String? _selectedRouteNumber;
//   Set<Polyline> _directionsPolyline = {};
//   Set<Polyline> _routePolyline = {};
//   List<String> _routeStops = [];
//   bool _tripStopped = false;
//   late final BusSignalRService _busSignalRService;

//   // Helper to update _routeStops based on current start/destination and widget.routeStops
//   void _updateRouteStopsFromFields() {
//     if (widget.routeStops != null && widget.routeStops!.isNotEmpty) {
//       final start = _startController.text.trim();
//       final destination = _destinationController.text.trim();
//       final stops = List<String>.from(widget.routeStops!);
//       final startIdx = stops.indexOf(start);
//       final endIdx = stops.indexOf(destination);
//       if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
//         setState(() {
//           _routeStops = stops.sublist(startIdx, endIdx + 1);
//         });
//         _saveFormData(); // Save updated route stops
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Debug log to check if bus number plate was passed
//     print('[LiveMapScreen] selectedBusNumberPlate (passed): \'${widget.selectedBusNumberPlate}\'');
//     _loadFormData();
    
//     // Add listeners to save data on text changes
//     _startController.addListener(_saveFormData);
//     _destinationController.addListener(_saveFormData);

//     if (widget.routeStops != null) {
//       _routeStops = List<String>.from(widget.routeStops!);
//     }
    
//     // Set up initial camera position
//     final config = LiveMapService.getMapConfig();
//     final cam = config['initialCameraPosition'];
//     _initialCameraPosition = CameraPosition(
//       target: LatLng(cam['latitude'], cam['longitude']),
//       zoom: cam['zoom'].toDouble(),
//       bearing: cam['bearing']?.toDouble() ?? 0,
//       tilt: cam['tilt']?.toDouble() ?? 0,
//     );
    
//     _getAndUpdateCurrentLocation();
    
//     // Fetch map markers
//     LiveMapService.fetchAndAddBusStopMarkers().then((_) {
//       if (!mounted) return;
//       setState(() {
//         _mapMarkers = LiveMapService.getMarkers();
//       });
//     });
//     LiveMapService.fetchAndAddFamousPlaceMarkers();

//     // Fetch and draw the route polyline if arguments are provided
//     if (widget.startLocation != null && widget.destinationLocation != null &&
//         widget.startLocation!.isNotEmpty && widget.destinationLocation!.isNotEmpty) {
//       _startController.text = widget.startLocation!;
//       _destinationController.text = widget.destinationLocation!;
//       _fetchAndAddDirectionsPolylineFromBusStops();
//     }

//     setState(() {
//       _mapMarkers = LiveMapService.getMarkers();
//       _mapPolylines = LiveMapService.getPolylines();
//     });

//     _busSignalRService = BusSignalRService();
//     _busSignalRService.onBusLocationUpdate = (busId, latitude, longitude) async {
//       // Debug log to check if bus number plate is used correctly
//       print('[LiveMapScreen] onBusLocationUpdate: busId=\'$busId\', selectedBusNumberPlate=\'${widget.selectedBusNumberPlate}\'');
//       // Only show the marker if this is the selected bus
//       if (busId == widget.selectedBusNumberPlate) {
//         final blueBoxIcon = await LiveMapService.getBlueBoxIcon();
//         setState(() {
//           // Remove all other bus markers
//           _mapMarkers.removeWhere((m) => m.markerId.value.startsWith('bus_'));
//           // Add or update the selected bus marker
//           _mapMarkers.add(
//             Marker(
//               markerId: MarkerId('bus_$busId'),
//               position: LatLng(latitude, longitude),
//               icon: blueBoxIcon,
//               infoWindow: InfoWindow(title: 'Bus $busId'),
//             ),
//           );
//         });
//       }
//     };
//     _busSignalRService.connect();
//   }

//   Future<void> _getAndUpdateCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//     if (permission == LocationPermission.deniedForever) return;
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     await LiveMapService.updatePassengerLocation(
//       passengerId: widget.passengerId,
//       latitude: position.latitude,
//       longitude: position.longitude,
//       passengerName: 'ME',
//     );
//     setState(() {
//       _mapMarkers = LiveMapService.getMarkers();
//     });
//   }

//   Future<void> _fetchAndAddDirectionsPolylineFromBusStops() async {
//     // 1. Fetch bus stop geojson to map stop names to coordinates
//     const busStopGeoJsonUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson';
//     try {
//       final response = await http.get(Uri.parse(busStopGeoJsonUrl));
//       if (response.statusCode != 200) {
//         print('[Directions] Failed to fetch bus stop geojson');
//         return;
//       }
//       final geoJson = jsonDecode(response.body);
//       if (geoJson['features'] is! List) return;
//       final features = geoJson['features'] as List;
//       LatLng? startCoord;
//       LatLng? endCoord;
//       final stopNameToCoord = <String, LatLng>{};
//       for (final feature in features) {
//         if (feature['geometry']?['type'] == 'Point' && feature['geometry']?['coordinates'] is List && feature['properties'] != null) {
//           final coords = feature['geometry']['coordinates'];
//           final lat = coords[1];
//           final lng = coords[0];
//           final name = feature['properties']['name'] ?? '';
//           stopNameToCoord[name] = LatLng(lat, lng);
//           if (name == _startController.text.trim()) {
//             startCoord = LatLng(lat, lng);
//           }
//           if (name == _destinationController.text.trim()) {
//             endCoord = LatLng(lat, lng);
//           }
//         }
//       }
//       if (startCoord != null && endCoord != null) {
//         // Use all stops between start and end as waypoints
//         List<LatLng> waypoints = [];
//         if (_routeStops.isNotEmpty) {
//           final stops = _routeStops;
//           final startIdx = stops.indexOf(_startController.text.trim());
//           final endIdx = stops.indexOf(_destinationController.text.trim());
//           if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
//             for (int i = startIdx + 1; i < endIdx; i++) {
//               final stopName = stops[i];
//               if (stopNameToCoord.containsKey(stopName)) {
//                 waypoints.add(stopNameToCoord[stopName]!);
//               }
//             }
//         }
//         final polyline = await LiveMapService.fetchDirectionsPolyline(start: startCoord, end: endCoord, waypoints: waypoints);
//         if (polyline != null) {
//           if (!mounted) return;
//           setState(() {
//             _routePolyline = {polyline};
//           });
//           _saveFormData(); // Save route polyline
//         }
//       } else {
//         print('[Directions] Start or end bus stop not found');
//       }
//     } catch (e) {
//       print('[Directions] Error: $e');
//     }
//   }

//     // Required changes for SharedPreferences persistence

//   // 1. ADD THESE METHODS TO _LiveMapScreenState class (around line 200-250):

//   // Save form data to SharedPreferences
//   Future<void> _saveFormData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('live_map_start_location', _startController.text);
//       await prefs.setString('live_map_destination_location', _destinationController.text);
//       await prefs.setBool('live_map_is_swapped', isSwapped);
//       // Save route stops if available
//       if (_routeStops.isNotEmpty) {
//         await prefs.setStringList('live_map_route_stops', _routeStops);
//       }
//       // Save selected route number if available
//       if (_selectedRouteNumber != null) {
//         await prefs.setString('live_map_selected_route', _selectedRouteNumber!);
//       }
//       print('[LiveMapScreen] Form data saved to SharedPreferences: start=${_startController.text}, dest=${_destinationController.text}');
//     } catch (e) {
//       print('[LiveMapScreen] Error saving form data: $e');
//     }
//   }

//   // Load form data from SharedPreferences (always takes precedence)
//   Future<void> _loadFormData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedStart = prefs.getString('live_map_start_location') ?? '';
//       final savedDestination = prefs.getString('live_map_destination_location') ?? '';
//       if (savedStart.isNotEmpty) {
//         _startController.text = savedStart;
//       }
//       if (savedDestination.isNotEmpty) {
//         _destinationController.text = savedDestination;
//       }
//       // Load other saved state
//       isSwapped = prefs.getBool('live_map_is_swapped') ?? false;
//       // Load route stops if widget doesn't provide them
//       if (widget.routeStops == null || widget.routeStops!.isEmpty) {
//         final savedStops = prefs.getStringList('live_map_route_stops') ?? [];
//         if (savedStops.isNotEmpty) {
//           _routeStops = savedStops;
//         }
//       }
//       // Load selected route
//       _selectedRouteNumber = prefs.getString('live_map_selected_route');
//       print('[LiveMapScreen] Form data loaded from SharedPreferences: start=${_startController.text}, dest=${_destinationController.text}');
//     } catch (e) {
//       print('[LiveMapScreen] Error loading form data: $e');
//     }
//   }

//   // Add this method to clear all trip-related SharedPreferences and reset state
//   Future<void> _resetTripData() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Clear keys for both live_map_scren.dart and trip_planner_screen.dart
//     await prefs.remove('live_map_start_location');
//     await prefs.remove('live_map_destination_location');
//     await prefs.remove('live_map_is_swapped');
//     await prefs.remove('live_map_route_stops');
//     await prefs.remove('live_map_selected_route');
//     await prefs.remove('start_location');
//     await prefs.remove('destination_location');
//     await prefs.remove('selected_start_location');
//     await prefs.remove('selected_destination_location');
//     setState(() {
//       _startController.text = '';
//       _destinationController.text = '';
//       isSwapped = false;
//       _routeStops = [];
//       _selectedRouteNumber = null;
//       _routePolyline = {};
//       _tripStopped = true;
//     });
//     print('[LiveMapScreen] Trip data reset for both LiveMap and TripPlanner');
//   }

//   Widget _buildStopTripButton() {
//     if (_tripStopped) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           onPressed: _resetTripData,
//           child: const Text(
//             'Stop Trip',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // No longer overwrite controllers from widget arguments. SharedPreferences always takes precedence.
//     print('[LiveMapScreen] didChangeDependencies - Widget arguments: startLocation=${widget.startLocation}, destinationLocation=${widget.destinationLocation}');
//   }

//   // Removed map config loading logic

//   @override
//   void dispose() {
//     _busSignalRService.disconnect();
//     // Remove listeners before disposing
//     _startController.removeListener(_saveFormData);
//     _destinationController.removeListener(_saveFormData);
//     _startController.dispose();
//     _destinationController.dispose();
//     super.dispose();
//   }

//   // Add this method to your _LiveMapScreenState class
//   // Remove TripPlanStorage and all persistence logic
//   // Only use widget.startLocation, widget.destinationLocation, and widget.routeStops
//   // Remove _saveTripData, _loadTripData, and all listeners related to saving
//   // Remove any import of trip_plan_storage_helper.dart
//   // Remove any code that references TripPlanStorage
//   // Remove any code that loads or saves trip data from storage
//   // The screen should only use the arguments passed to it

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(color: Color.fromARGB(255, 247, 155, 51)),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.pushReplacementNamed(
//                 context,
//                 '/home',
//                 arguments: {'passengerId': widget.passengerId},
//               );
//             },
//             child: const Icon(Icons.arrow_back, color: Colors.white),
//           ),
//           const SizedBox(width: 12),
//           const Text(
//             "Live Map",
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputFields() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(height: 14),
//               const Icon(
//                 Icons.radio_button_unchecked,
//                 size: 20,
//                 color: Colors.black,
//               ),
//               const SizedBox(height: 6),
//               DottedLine(
//                 direction: Axis.vertical,
//                 dashLength: 3,
//                 dashGapLength: 2,
//                 lineThickness: 1,
//                 dashColor: Colors.grey.shade500,
//                 lineLength: 24,
//               ),
//               const SizedBox(height: 6),
//               const Icon(Icons.location_pin, size: 22, color: Colors.red),
//             ],
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   height: 44,
//                   child: TextField(
//                     controller: _startController,
//                     onChanged: (value) {
//                       _saveFormData();
//                       _updateRouteStopsFromFields();
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Choose starting point",
//                       hintStyle: const TextStyle(color: Colors.black54),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 0,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFBD2D01),
//                           width: 1.2,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFBD2D01),
//                           width: 1.2,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFBD2D01), // Same color as enabled
//                           width: 1.2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 44,
//                   child: TextField(
//                     controller: _destinationController,
//                     onChanged: (value) {
//                       _saveFormData();
//                       _updateRouteStopsFromFields();
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Choose destination",
//                       hintStyle: const TextStyle(color: Colors.black54),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 0,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFBD2D01),
//                           width: 1.2,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFBD2D01),
//                           width: 1.2,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: const BorderSide(
//                           color: Color(
//                             0xFFBD2D01,
//                           ), // Same color to prevent change
//                           width: 1.2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 isSwapped = !isSwapped;
//                 final temp = _startController.text;
//                 _startController.text = _destinationController.text;
//                 _destinationController.text = temp;
//               });
//               _saveFormData();
//             },
//             child: AnimatedRotation(
//               turns: isSwapped ? 0.5 : 0,
//               duration: const Duration(milliseconds: 300),
//               child: const Icon(Icons.swap_vert, color: Colors.black, size: 24),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTripLabel() {
//     if (_tripStopped) {
//       // Always show default label if trip is stopped
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.orange, size: 20),
//             const SizedBox(width: 8),
//             const Text('No trip planned', style: TextStyle(fontSize: 16, color: Colors.black87)),
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pushReplacementNamed(context, '/tripPlanner', arguments: {'passengerId': widget.passengerId});
//               },
//               child: const Text('Plan a trip', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
//             ),
//           ],
//         ),
//       );
//     }
//     final hasTrip = _startController.text.isNotEmpty && _destinationController.text.isNotEmpty;
//     if (!hasTrip) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.orange, size: 20),
//             const SizedBox(width: 8),
//             const Text('No trip planned', style: TextStyle(fontSize: 16, color: Colors.black87)),
//             const SizedBox(width: 8),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pushReplacementNamed(context, '/tripPlanner', arguments: {'passengerId': widget.passengerId});
//               },
//               child: const Text('Plan a trip', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Icon column
//             Column(
//               children: [
//                 Icon(Icons.radio_button_unchecked, size: 20, color: Colors.black),
//                 DottedLine(
//                   direction: Axis.vertical,
//                   dashLength: 3,
//                   dashGapLength: 2,
//                   lineThickness: 1,
//                   dashColor: Colors.grey,
//                   lineLength: 24,
//                 ),
//                 Icon(Icons.location_pin, size: 22, color: Colors.red),
//               ],
//             ),
//             const SizedBox(width: 10),
//             // Text column, aligned with icons
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 20, // Match icon height
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _startController.text,
//                       style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12), // Match dotted line + spacing
//                 SizedBox(
//                   height: 22, // Match icon height
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _destinationController.text,
//                       style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Widget _buildMap() {
//     final config = LiveMapService.getMapConfig();
//     final mapOptions = config['mapOptions'];
//     final styles = mapOptions['styles'];
//     final allPolylines = <Polyline>{}..addAll(_mapPolylines)..addAll(_routePolyline);
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade400, width: 1.0),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: GoogleMap(
//             initialCameraPosition: _initialCameraPosition,
//             markers: _mapMarkers,
//             polylines: allPolylines,
//             myLocationEnabled: mapOptions['myLocationButtonEnabled'] ?? true,
//             myLocationButtonEnabled: mapOptions['myLocationButtonEnabled'] ?? true,
//             zoomControlsEnabled: mapOptions['zoomControlsEnabled'] ?? true,
//             mapType: MapType.normal,
//             onMapCreated: (GoogleMapController controller) async {
//               _mapController = controller;
//               // Apply map style if needed
//               if (styles != null) {
//                 if (styles is List) {
//                   final styleJson = const JsonEncoder().convert(styles);
//                   await controller.setMapStyle(styleJson);
//                 }
//               }
//             },
//             onCameraMoveStarted: () {
//               setState(() {
//                 _isMapInteracting = true;
//               });
//             },
//             onCameraIdle: () {
//               setState(() {
//                 _isMapInteracting = false;
//               });
//             },
//             onTap: (LatLng position) {},
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     final iconList = [
//       Icons.home,
//       Icons.search,
//       Icons.location_on,
//       Icons.favorite,
//       Icons.notifications,
//       Icons.menu,
//     ];

//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey, width: 0.6)),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: List.generate(iconList.length, (index) {
//           bool isSelected = index == _selectedIndex;

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedIndex = index;
//               });

//               switch (index) {
//                 case 0:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/home',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/tripPlanner',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/liveMap',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//                 case 3:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/favourites',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//                 case 4:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/notifications',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//                 case 5:
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/more',
//                     arguments: {'passengerId': widget.passengerId},
//                   );
//                   break;
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: isSelected
//                     ? const LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Color(0xFFBD2D01),
//                           Color(0xFFCF4602),
//                           Color(0xFFF67F00),
//                           Color(0xFFCF4602),
//                           Color(0xFFBD2D01),
//                         ],
//                       )
//                     : null,
//                 color: isSelected ? null : Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 3,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 iconList[index],
//                 size: 22,
//                 color: isSelected ? Colors.white : const Color(0xFFBD2D01),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: GestureDetector(
//         onTap: () {
//           // Dismiss keyboard or overlays if needed
//         },
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               _buildTripLabel(),
//               NotificationListener<ScrollNotification>(
//                 onNotification: (notification) => _isMapInteracting,
//                 child: _buildMap(),
//               ),
//               _buildStopTripButton(), // Add the Stop Trip button here
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavBar(),
//     );
//   }
// }

class LiveMapScreen extends StatefulWidget {
  final String passengerId;
  final String? startLocation;
  final String? destinationLocation;
  final CameraPosition? cameraPosition;
  final String? busRouteGeoJsonUrl;
  final List<dynamic>? routeStops;
  final String? selectedBusNumberPlate; // Added for filtering bus updates

  const LiveMapScreen({
    Key? key,
    required this.passengerId,
    this.startLocation,
    this.destinationLocation,
    this.cameraPosition,
    this.busRouteGeoJsonUrl,
    this.routeStops,
    this.selectedBusNumberPlate, // Added for filtering bus updates
  }) : super(key: key);

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  int _selectedIndex = 2;
  bool isSwapped = false;
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  // Removed SignalR, MapService, and map state fields
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 12.0,
  );
  bool _isMapInteracting = false;
  bool _isLoadingMap = false;
  String? _mapErrorMessage;
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};
  Set<Polyline> _mapPolylines = {};
  String? _selectedRouteNumber;
  Set<Polyline> _directionsPolyline = {};
  Set<Polyline> _routePolyline = {};
  List<String> _routeStops = [];
  bool _tripStopped = false;
  late final BusSignalRService _busSignalRService;
  Set<Marker> _favoritePlaceMarkers = {};

  // Helper to update _routeStops based on current start/destination and widget.routeStops
  void _updateRouteStopsFromFields() {
    if (widget.routeStops != null && widget.routeStops!.isNotEmpty) {
      final start = _startController.text.trim();
      final destination = _destinationController.text.trim();
      final stops = List<String>.from(widget.routeStops!);
      final startIdx = stops.indexOf(start);
      final endIdx = stops.indexOf(destination);
      if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
        setState(() {
          _routeStops = stops.sublist(startIdx, endIdx + 1);
        });
        _saveFormData(); // Save updated route stops when fields change
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Debug log to check if bus number plate was passed
    print('[LiveMapScreen] selectedBusNumberPlate (passed): \'${widget.selectedBusNumberPlate}\'');
    
    // Load persisted data first
    _loadFormData();
    _loadFavoritePlaces();

    // Add listeners to save data on text changes
    _startController.addListener(_saveFormData);
    _destinationController.addListener(_saveFormData);

    // Set up initial camera position
    final config = LiveMapService.getMapConfig();
    final cam = config['initialCameraPosition'];
    _initialCameraPosition = CameraPosition(
      target: LatLng(cam['latitude'], cam['longitude']),
      zoom: cam['zoom'].toDouble(),
      bearing: cam['bearing']?.toDouble() ?? 0,
      tilt: cam['tilt']?.toDouble() ?? 0,
    );
    
    _getAndUpdateCurrentLocation();
    
    // Fetch map markers
    LiveMapService.fetchAndAddBusStopMarkers().then((_) {
      if (!mounted) return;
      setState(() {
        _mapMarkers = LiveMapService.getMarkers();
      });
    });
    LiveMapService.fetchAndAddFamousPlaceMarkers();

    // Fetch and draw the route polyline if start/destination are available
    // This will be called regardless of whether data came from widget or persistence.
    if (_startController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
      _fetchAndAddDirectionsPolylineFromBusStops();
      _tripStopped = false; // A trip is active if controllers have values
    } else {
      _tripStopped = true; // No trip if controllers are empty
    }

    setState(() {
      _mapMarkers = LiveMapService.getMarkers();
      _mapPolylines = LiveMapService.getPolylines();
    });

    _busSignalRService = BusSignalRService();
    _busSignalRService.onBusLocationUpdate = (busId, latitude, longitude) async {
      // Debug log to check if bus number plate is used correctly
      print('[LiveMapScreen] onBusLocationUpdate: busId=\'$busId\', selectedBusNumberPlate=\'${widget.selectedBusNumberPlate}\'');
      print("[LiveMapScreen] _tripStopped: $_tripStopped");
      // Only show the marker if this is the selected bus AND a trip is active
      if (busId == widget.selectedBusNumberPlate && !_tripStopped) {
        final blueBoxIcon = await LiveMapService.getBlueBoxIcon();
        setState(() {
          // Remove all other bus markers
          _mapMarkers.removeWhere((m) => m.markerId.value.startsWith('bus_'));
          // Add or update the selected bus marker
          _mapMarkers.add(
            Marker(
              markerId: MarkerId('bus_$busId'),
              position: LatLng(latitude, longitude),
              icon: blueBoxIcon,
              infoWindow: InfoWindow(title: 'Bus $busId'),
            ),
          );
        });
      }
    };
    _busSignalRService.onBusLocationRemove = (busId) {
      print('[LiveMapScreen] onBusLocationRemove: busId=\'$busId\', selectedBusNumberPlate=\'${widget.selectedBusNumberPlate}\'');
      // Remove the bus marker if it matches the selected bus
      if (busId == widget.selectedBusNumberPlate) {
        setState(() {
          _mapMarkers.removeWhere((m) => m.markerId.value == 'bus_$busId');
        });
        print('[LiveMapScreen] Removed bus marker for: $busId');
      }
    };
    _busSignalRService.connect();
    // Set the current trip bus number plate for notifications
    NotificationSignalRService.instance.setCurrentTripBusNumberPlate(widget.selectedBusNumberPlate);
  }

  Future<void> _loadFavoritePlaces() async {
    try {
      final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/${widget.passengerId}/favorite-places';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favoritePlaces = data['favoritePlaces'] ?? [];
        final redDotIcon = await LiveMapService.getRedDotIcon();
        setState(() {
          _favoritePlaceMarkers = favoritePlaces.map((place) => Marker(
            markerId: MarkerId('favorite_${place['placeName']}'),
            position: LatLng(place['latitude'], place['longitude']),
            icon: redDotIcon,
            infoWindow: InfoWindow(title: place['placeName']),
          )).toSet();
        });
      } else {
        setState(() {
          _favoritePlaceMarkers = {};
        });
      }
    } catch (e) {
      setState(() {
        _favoritePlaceMarkers = {};
      });
    }
  }

  Future<void> _getAndUpdateCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await LiveMapService.updatePassengerLocation(
      passengerId: widget.passengerId,
      latitude: position.latitude,
      longitude: position.longitude,
      passengerName: 'ME',
    );
    setState(() {
      _mapMarkers = LiveMapService.getMarkers();
    });
  }

  Future<void> _fetchAndAddDirectionsPolylineFromBusStops() async {
    // 1. Fetch bus stop geojson to map stop names to coordinates
    const busStopGeoJsonUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/busstop/geojson';
    try {
      final response = await http.get(Uri.parse(busStopGeoJsonUrl));
      if (response.statusCode != 200) {
        print('[Directions] Failed to fetch bus stop geojson');
        return;
      }
      final geoJson = jsonDecode(response.body);
      if (geoJson['features'] is! List) return;
      final features = geoJson['features'] as List;
      LatLng? startCoord;
      LatLng? endCoord;
      final stopNameToCoord = <String, LatLng>{};
      for (final feature in features) {
        if (feature['geometry']?['type'] == 'Point' && feature['geometry']?['coordinates'] is List && feature['properties'] != null) {
          final coords = feature['geometry']['coordinates'];
          final lat = coords[1];
          final lng = coords[0];
          final name = feature['properties']['name'] ?? '';
          stopNameToCoord[name] = LatLng(lat, lng);
          if (name == _startController.text.trim()) {
            startCoord = LatLng(lat, lng);
          }
          if (name == _destinationController.text.trim()) {
            endCoord = LatLng(lat, lng);
          }
        }
      }
      if (startCoord != null && endCoord != null) {
        // Use all stops between start and end as waypoints
        List<LatLng> waypoints = [];
        if (_routeStops.isNotEmpty) {
          final stops = _routeStops;
          final startIdx = stops.indexOf(_startController.text.trim());
          final endIdx = stops.indexOf(_destinationController.text.trim());
          if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
            for (int i = startIdx + 1; i < endIdx; i++) {
              final stopName = stops[i];
              if (stopNameToCoord.containsKey(stopName)) {
                waypoints.add(stopNameToCoord[stopName]!);
              }
            }
          }
        }
        final polyline = await LiveMapService.fetchDirectionsPolyline(start: startCoord, end: endCoord, waypoints: waypoints);
        if (polyline != null) {
          if (!mounted) return;
          setState(() {
            _routePolyline = {polyline};
          });
          _saveFormData(); // Save route polyline info indirectly by saving start/dest/stops
        }
      } else {
        print('[Directions] Start or end bus stop not found');
      }
    } catch (e) {
      print('[Directions] Error: $e');
    }
  }

  // Save form data to SharedPreferences
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('live_map_start_location', _startController.text);
      await prefs.setString('live_map_destination_location', _destinationController.text);
      await prefs.setBool('live_map_is_swapped', isSwapped);
      // Save route stops if available
      if (_routeStops.isNotEmpty) {
        await prefs.setStringList('live_map_route_stops', _routeStops);
      }
      // Save selected route number if available (though it's not being set in this code block)
      if (_selectedRouteNumber != null) {
        await prefs.setString('live_map_selected_route', _selectedRouteNumber!);
      }
      print('[LiveMapScreen] Form data saved to SharedPreferences: start=${_startController.text}, dest=${_destinationController.text}');
    } catch (e) {
      print('[LiveMapScreen] Error saving form data: $e');
    }
  }

  // Load form data from SharedPreferences, overriding with widget arguments if provided
  Future<void> _loadFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('[LiveMapScreen] Loading form data from SharedPreferences...: ${prefs}');

      // Prioritize widget arguments if they are provided (not null and not empty)
      if (widget.startLocation != null && widget.startLocation!.isNotEmpty) {
        _startController.text = widget.startLocation!;
      } else {
        _startController.text = prefs.getString('live_map_start_location') ?? '';
      }

      if (widget.destinationLocation != null && widget.destinationLocation!.isNotEmpty) {
        _destinationController.text = widget.destinationLocation!;
      } else {
        _destinationController.text = prefs.getString('live_map_destination_location') ?? '';
      }

      // Load other saved state, but don't override if widget provides specific routeStops
      isSwapped = prefs.getBool('live_map_is_swapped') ?? false;

      if (widget.routeStops != null && widget.routeStops!.isNotEmpty) {
        _routeStops = List<String>.from(widget.routeStops!);
      } else {
        final savedStops = prefs.getStringList('live_map_route_stops') ?? [];
        if (savedStops.isNotEmpty) {
          _routeStops = savedStops;
        }
      }
      
      // Load selected route (no widget argument for this, so always from prefs)
      _selectedRouteNumber = prefs.getString('live_map_selected_route');

      // Update _tripStopped based on whether we have a start and destination
      _tripStopped = !(_startController.text.isNotEmpty && _destinationController.text.isNotEmpty);

      print('[LiveMapScreen] Form data loaded from SharedPreferences (and potentially overridden by arguments): start=${_startController.text}, dest=${_destinationController.text}');
    } catch (e) {
      print('[LiveMapScreen] Error loading form data: $e');
    }
  }

  // Add this method to clear all trip-related SharedPreferences and reset state
  Future<void> _resetTripData() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear keys for both live_map_scren.dart and trip_planner_screen.dart
    await prefs.remove('live_map_start_location');
    await prefs.remove('live_map_destination_location');
    await prefs.remove('live_map_is_swapped');
    await prefs.remove('live_map_route_stops');
    await prefs.remove('live_map_selected_route');
    await prefs.remove('start_location'); // Clearing for TripPlanner as well
    await prefs.remove('destination_location'); // Clearing for TripPlanner as well
    await prefs.remove('selected_start_location'); // Clearing for TripPlanner as well
    await prefs.remove('selected_destination_location'); // Clearing for TripPlanner as well

    setState(() {
      _startController.text = '';
      _destinationController.text = '';
      isSwapped = false;
      _routeStops = [];
      _selectedRouteNumber = null;
      _routePolyline = {}; // Clear polyline when trip is stopped
      _mapMarkers.removeWhere((m) => m.markerId.value.startsWith('bus_')); // Clear bus marker
      _tripStopped = true; // Set trip as stopped
    });
    // Clear the current trip bus number plate for notifications
    NotificationSignalRService.instance.setCurrentTripBusNumberPlate(null);
    print('[LiveMapScreen] Trip data reset for both LiveMap and TripPlanner');
  }

  Widget _buildStopTripButton() {
    // Only show the stop trip button if a trip is considered active
    if (_tripStopped || (_startController.text.isEmpty && _destinationController.text.isEmpty)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _resetTripData,
          child: const Text(
            'Stop Trip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is where we ensure widget arguments override loaded data on subsequent rebuilds
    // (e.g., if you navigate back to this screen with new arguments)
    print('[LiveMapScreen] didChangeDependencies - Widget arguments: startLocation=${widget.startLocation}, destinationLocation=${widget.destinationLocation}');

    bool hasNewArgs = false;
    if (widget.startLocation != null && widget.startLocation!.isNotEmpty && _startController.text != widget.startLocation) {
      _startController.text = widget.startLocation!;
      hasNewArgs = true;
    }
    if (widget.destinationLocation != null && widget.destinationLocation!.isNotEmpty && _destinationController.text != widget.destinationLocation) {
      _destinationController.text = widget.destinationLocation!;
      hasNewArgs = true;
    }
    if (widget.routeStops != null && widget.routeStops!.isNotEmpty && _routeStops.join(',') != List<String>.from(widget.routeStops!).join(',')) {
      _routeStops = List<String>.from(widget.routeStops!);
      hasNewArgs = true;
    }

    if (hasNewArgs) {
      // If arguments caused a change, re-fetch polyline and save new state
      _fetchAndAddDirectionsPolylineFromBusStops();
      _saveFormData(); // Save the new data that came from widget arguments
      setState(() {
        _tripStopped = false; // A trip is active with new arguments
      });
    } else if (_startController.text.isEmpty && _destinationController.text.isEmpty) {
        // If no args and no data in controllers (meaning prefs was empty too)
        setState(() {
            _tripStopped = true;
        });
    }
    // Update the current trip bus number plate if arguments change
    NotificationSignalRService.instance.setCurrentTripBusNumberPlate(widget.selectedBusNumberPlate);
  }

  @override
  void dispose() {
    _busSignalRService.disconnect();
    // Remove listeners before disposing
    _startController.removeListener(_saveFormData);
    _destinationController.removeListener(_saveFormData);
    _startController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color.fromARGB(255, 247, 155, 51)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/home',
                arguments: {'passengerId': widget.passengerId},
              );
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Live Map",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    // These are now for displaying the current active trip, not for user input.
    // The _buildTripLabel below provides the same visual and is more appropriate.
    // I'm keeping this here but it's not being used in the build method anymore.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const Icon(
                Icons.radio_button_unchecked,
                size: 20,
                color: Colors.black,
              ),
              const SizedBox(height: 6),
              DottedLine(
                direction: Axis.vertical,
                dashLength: 3,
                dashGapLength: 2,
                lineThickness: 1,
                dashColor: Colors.grey.shade500,
                lineLength: 24,
              ),
              const SizedBox(height: 6),
              const Icon(Icons.location_pin, size: 22, color: Colors.red),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _startController,
                    readOnly: true, // Make read-only
                    decoration: InputDecoration(
                      hintText: "Choose starting point",
                      hintStyle: const TextStyle(color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFBD2D01),
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFBD2D01),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFBD2D01), // Same color as enabled
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _destinationController,
                    readOnly: true, // Make read-only
                    decoration: InputDecoration(
                      hintText: "Choose destination",
                      hintStyle: const TextStyle(color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFBD2D01),
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFBD2D01),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(
                            0xFFBD2D01,
                          ), // Same color to prevent change
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              // Swapping in read-only fields for display, but this won't change the underlying trip data.
              // If this is meant to change the trip direction, you'd need more complex logic.
              setState(() {
                isSwapped = !isSwapped;
                final temp = _startController.text;
                _startController.text = _destinationController.text;
                _destinationController.text = temp;
              });
              _saveFormData(); // Save the swap state
            },
            child: AnimatedRotation(
              turns: isSwapped ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.swap_vert, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripLabel() {
    final hasTrip = _startController.text.isNotEmpty && _destinationController.text.isNotEmpty;
    // _tripStopped state correctly reflects if there's an active trip based on controllers
    _tripStopped = !hasTrip;

    if (_tripStopped) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text('No trip planned', style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/tripPlanner', arguments: {'passengerId': widget.passengerId});
              },
              child: const Text('Plan a trip', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon column
            Column(
              children: [
                Icon(Icons.radio_button_unchecked, size: 20, color: Colors.black),
                DottedLine(
                  direction: Axis.vertical,
                  dashLength: 3,
                  dashGapLength: 2,
                  lineThickness: 1,
                  dashColor: Colors.grey,
                  lineLength: 24,
                ),
                Icon(Icons.location_pin, size: 22, color: Colors.red),
              ],
            ),
            const SizedBox(width: 10),
            // Text column, aligned with icons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20, // Match icon height
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _startController.text,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 12), // Match dotted line + spacing
                SizedBox(
                  height: 22, // Match icon height
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _destinationController.text,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMap() {
    final config = LiveMapService.getMapConfig();
    final mapOptions = config['mapOptions'];
    final styles = mapOptions['styles'];
    final allPolylines = <Polyline>{}..addAll(_mapPolylines)..addAll(_routePolyline);
    final allMarkers = <Marker>{}..addAll(_mapMarkers)..addAll(_favoritePlaceMarkers);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: allMarkers,
            polylines: allPolylines,
            myLocationEnabled: mapOptions['myLocationButtonEnabled'] ?? true,
            myLocationButtonEnabled: mapOptions['myLocationButtonEnabled'] ?? true,
            zoomControlsEnabled: mapOptions['zoomControlsEnabled'] ?? true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              // Apply map style if needed
              if (styles != null) {
                if (styles is List) {
                  final styleJson = const JsonEncoder().convert(styles);
                  await controller.setMapStyle(styleJson);
                }
              }
            },
            onCameraMoveStarted: () {
              setState(() {
                _isMapInteracting = true;
              });
            },
            onCameraIdle: () {
              setState(() {
                _isMapInteracting = false;
              });
            },
            onTap: (LatLng position) {},
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final iconList = [
      Icons.home,
      Icons.search,
      Icons.location_on,
      Icons.favorite,
      Icons.notifications,
      Icons.menu,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(iconList.length, (index) {
          bool isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });

              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {'passengerId': widget.passengerId},
                  );
                  break;
                case 1:
                  Navigator.pushReplacementNamed(
                    context,
                    '/tripPlanner',
                    arguments: {'passengerId': widget.passengerId},
                  );
                  break;
                case 2:
                  Navigator.pushReplacementNamed(
                    context,
                    '/liveMap',
                    arguments: {'passengerId': widget.passengerId},
                  );
                  break;
                case 3:
                  Navigator.pushReplacementNamed(
                    context,
                    '/favourites',
                    arguments: {'passengerId': widget.passengerId, 'showBuses': true},
                  );
                  break;
                case 4:
                  Navigator.pushReplacementNamed(
                    context,
                    '/notifications',
                    arguments: {'passengerId': widget.passengerId},
                  );
                  break;
                case 5:
                  Navigator.pushReplacementNamed(
                    context,
                    '/more',
                    arguments: {'passengerId': widget.passengerId},
                  );
                  break;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFBD2D01),
                          Color(0xFFCF4602),
                          Color(0xFFF67F00),
                          Color(0xFFCF4602),
                          Color(0xFFBD2D01),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                iconList[index],
                size: 22,
                color: isSelected ? Colors.white : const Color(0xFFBD2D01),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard or overlays if needed
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTripLabel(), // This now shows the current trip state
              NotificationListener<ScrollNotification>(
                onNotification: (notification) => _isMapInteracting,
                child: _buildMap(),
              ),
              _buildStopTripButton(), // Add the Stop Trip button here
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}