import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import '../MapService.dart';

class TripPlannerScreen extends StatefulWidget {
  final String passengerId;
  const TripPlannerScreen({Key? key, required this.passengerId})
    : super(key: key);

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _selectedIndex = 1;
  bool isSwapped = false;
  bool showPanel = false; // Show bottom panel after search
  int expandedIndex = -1; // For expanding/collapsing itinerary details
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Bus stop search variables
  List<Map<String, dynamic>> _startSuggestions = [];
  List<Map<String, dynamic>> _destinationSuggestions = [];
  bool _showStartSuggestions = false;
  bool _showDestinationSuggestions = false;
  bool _isLoadingStart = false;
  bool _isLoadingDestination = false;

  // Store selected locations
  String _selectedStartLocation = "";
  String _selectedDestinationLocation = "";

  // Store date and time when trip planning is initiated
  String _tripPlanningDate = "";
  String _tripPlanningTime = "";

  // Store fetched bus routes
  List<Map<String, dynamic>> _busRoutes = [];
  bool _isLoadingBusRoutes = false;

  // Map related variables
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};
  Set<Polyline> _mapPolylines = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(6.9271, 79.8612), // Colombo, Sri Lanka
    zoom: 12,
  );
  bool _isLoadingMap = false;
  String? _mapErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadMapFromApi();
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  // Get the correct base URL for API calls
  String _getBaseUrl() {
    // Use the Heroku API URL
    return 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com';
  }

  // Load map from API
  Future<void> _loadMapFromApi() async {
    setState(() {
      _isLoadingMap = true;
      _mapErrorMessage = null;
    });

    try {
      final baseUrl = _getBaseUrl();
      final url =
          '$baseUrl/api/Map/passenger-view-live-location?passenger=${widget.passengerId}';
      print('Attempting to connect to: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Convert API response to MapService format
        final mapConfig = {
          "googleMapsApiKey": "AIzaSyAN397HAlCveqhw7idZNJHdhSidLl9rIKA",
          "initialCameraPosition": {
            "latitude": 6.9271,
            "longitude": 79.8612,
            "zoom": 12,
            "bearing": 0,
            "tilt": 0,
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
            "zoomGesturesEnabled": true,
          },
          "layers": [
            {
              "id": "passenger_live_location",
              "type": "geojson",
              "sourceUrl": url, // Use the same API URL as GeoJSON source
              "renderOptions": {
                "strokeColor": "#FF6B35",
                "strokeWidth": 4,
                "strokeOpacity": 0.8,
                "followRoads": true,
                "clusterMarkers": false,
                "markerIconUrl": null,
              },
            },
          ],
        };

        final result = await MapService.processMapConfiguration(mapConfig);

        if (result.success) {
          setState(() {
            _initialCameraPosition = result.initialCameraPosition;
            _mapMarkers = result.markers;
            _mapPolylines = result.polylines;
            _isLoadingMap = false;
          });

          // Set the map controller reference
          if (_mapController != null) {
            MapService.setMapController(_mapController!);
          }
        } else {
          setState(() {
            _mapErrorMessage = result.errorMessage;
            _isLoadingMap = false;
          });
        }
      } else {
        setState(() {
          _mapErrorMessage = 'Failed to load map data: ${response.statusCode}';
          _isLoadingMap = false;
        });
      }
    } catch (e) {
      print('Map loading error: $e');
      setState(() {
        _mapErrorMessage =
            'Connection failed. Please check:\n\n1. Internet connection is available\n2. Heroku API is accessible\n3. API endpoint is correct';
        _isLoadingMap = false;
      });
    }
  }

  // Helper method to format current date and time
  void _storeCurrentDateTime() {
    DateTime now = DateTime.now();

    // Format date as YYYY-MM-DD
    _tripPlanningDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Format time as HH:mm:ss (24 hour format)
    _tripPlanningTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    print(
      'Trip planning initiated on: $_tripPlanningDate at $_tripPlanningTime',
    );
  }

  // Fetch bus routes by stops
  Future<List<Map<String, dynamic>>> _fetchBusRoutes() async {
    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/BusRoute/by-stops';

      // Create request body with start and end stops
      // Try different parameter variations that might be expected by the API
      final requestBody = {
        'startStop': _selectedStartLocation,
        'endStop': _selectedDestinationLocation,
        'date': _tripPlanningDate,
        'time': _tripPlanningTime,
      };

      // Alternative parameter names that might be expected
      final alternativeRequestBody = {
        'startStop': _selectedStartLocation,
        'endStop': _selectedDestinationLocation,
        'date': _tripPlanningDate,
        'time': _tripPlanningTime,
      };

      // Try GET request with query parameters
      final uri = Uri.parse(url).replace(
        queryParameters: {
          'startingPoint': _selectedStartLocation,
          'endingPoint': _selectedDestinationLocation,
          'date': _tripPlanningDate,
          'time': _tripPlanningTime,
        },
      );

      print('=== DEBUG INFO ===');
      print('Selected start location: "$_selectedStartLocation"');
      print('Selected destination location: "$_selectedDestinationLocation"');
      print('Trip planning date: "$_tripPlanningDate"');
      print('Trip planning time: "$_tripPlanningTime"');
      print('Request URL: $uri');
      print(
        'Alternative request URL: ${Uri.parse(url).replace(queryParameters: alternativeRequestBody)}',
      );
      print('==================');

      final response = await http.get(uri);

      print('API Response status: ${response.statusCode}');
      print('API Response headers: ${response.headers}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed data length: ${data.length}');
        print('Parsed data: $data');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('Failed to fetch bus routes: ${response.statusCode}');
        print('Error response: ${response.body}');

        // Try with alternative parameter names using GET
        print('Trying with alternative parameter names...');
        final alternativeUri = Uri.parse(url).replace(
          queryParameters: {
            'startStop': _selectedStartLocation,
            'endStop': _selectedDestinationLocation,
            'date': _tripPlanningDate,
            'time': _tripPlanningTime,
          },
        );

        final alternativeResponse = await http.get(alternativeUri);

        print(
          'Alternative API Response status: ${alternativeResponse.statusCode}',
        );
        print('Alternative API Response body: ${alternativeResponse.body}');

        if (alternativeResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(alternativeResponse.body);
          print('Alternative parsed data length: ${data.length}');
          print('Alternative parsed data: $data');
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          print(
            'Alternative request also failed: ${alternativeResponse.statusCode}',
          );
          return [];
        }
      }
    } catch (e) {
      print('Error fetching bus routes: $e');
      print('Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Search bus stops for starting point
  Future<void> _searchStartStops(String query) async {
    if (query.length < 2) {
      setState(() {
        _startSuggestions = [];
        _showStartSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingStart = true;
      _showStartSuggestions = true;
    });

    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/BusStop/search/firebase/$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _startSuggestions = data
              .map(
                (item) => {
                  'stopName': item['stopName'],
                  'stopLatitude': item['stopLatitude'],
                  'stopLongitude': item['stopLongitude'],
                },
              )
              .toList();
          _isLoadingStart = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _startSuggestions = [];
          _isLoadingStart = false;
          _showStartSuggestions =
              true; // Keep showing the dropdown with "No stops found"
        });
      } else {
        setState(() {
          _startSuggestions = [];
          _isLoadingStart = false;
        });
      }
    } catch (e) {
      setState(() {
        _startSuggestions = [];
        _isLoadingStart = false;
      });
    }
  }

  // Search bus stops for destination
  Future<void> _searchDestinationStops(String query) async {
    if (query.length < 2) {
      setState(() {
        _destinationSuggestions = [];
        _showDestinationSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingDestination = true;
      _showDestinationSuggestions = true;
    });

    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/BusStop/search/firebase/$query';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _destinationSuggestions = data
              .map(
                (item) => {
                  'stopName': item['stopName'],
                  'stopLatitude': item['stopLatitude'],
                  'stopLongitude': item['stopLongitude'],
                },
              )
              .toList();
          _isLoadingDestination = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _destinationSuggestions = [];
          _isLoadingDestination = false;
          _showDestinationSuggestions =
              true; // Keep showing the dropdown with "No stops found"
        });
      } else {
        setState(() {
          _destinationSuggestions = [];
          _isLoadingDestination = false;
        });
      }
    } catch (e) {
      setState(() {
        _destinationSuggestions = [];
        _isLoadingDestination = false;
      });
    }
  }

  // Select start stop
  void _selectStartStop(Map<String, dynamic> stop) {
    setState(() {
      _startController.text = stop['stopName'];
      _selectedStartLocation = stop['stopName']; // Store the selected location
      _showStartSuggestions = false;
      _startSuggestions = [];
    });
    print('Selected start location: $_selectedStartLocation');
  }

  // Select destination stop
  void _selectDestinationStop(Map<String, dynamic> stop) {
    setState(() {
      _destinationController.text = stop['stopName'];
      _selectedDestinationLocation =
          stop['stopName']; // Store the selected location
      _showDestinationSuggestions = false;
      _destinationSuggestions = [];
    });
    print('Selected destination location: $_selectedDestinationLocation');
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
            "Trip Planner",
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vertical icons
          Column(
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

          // TextFields with suggestions
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Starting point field with suggestions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _startController,
                        focusNode: _startFocusNode,
                        onChanged: (value) {
                          _searchStartStops(value);
                        },
                        onSubmitted: (_) {
                          // Store the typed location and move focus to destination field
                          _selectedStartLocation = _startController.text;
                          _destinationFocusNode.requestFocus();
                          setState(() {
                            _showStartSuggestions = false;
                          });
                          print(
                            'Stored start location from typing: $_selectedStartLocation',
                          );
                        },
                        decoration: InputDecoration(
                          hintText: "Choose starting point",
                          hintStyle: const TextStyle(color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          border: _border(),
                          enabledBorder: _border(),
                          focusedBorder: _border(),
                        ),
                      ),
                    ),

                    // Start suggestions dropdown
                    if (_showStartSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isLoadingStart
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : _startSuggestions.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No stops found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _startSuggestions.length,
                                itemBuilder: (context, index) {
                                  final stop = _startSuggestions[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      stop['stopName'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => _selectStartStop(stop),
                                  );
                                },
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Destination field with suggestions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _destinationController,
                        focusNode: _destinationFocusNode,
                        onChanged: (value) {
                          _searchDestinationStops(value);
                        },
                        onSubmitted: (_) async {
                          // Store the typed destination location
                          _selectedDestinationLocation =
                              _destinationController.text;

                          // Store current date and time
                          _storeCurrentDateTime();

                          setState(() {
                            _isLoadingBusRoutes = true;
                            showPanel = true;
                            _showDestinationSuggestions = false;
                          });

                          // Fetch bus routes
                          final routes = await _fetchBusRoutes();

                          setState(() {
                            _busRoutes = routes;
                            _isLoadingBusRoutes = false;
                          });

                          print(
                            'Stored destination location from typing: $_selectedDestinationLocation',
                          );
                          print(
                            'Trip planning: $_selectedStartLocation → $_selectedDestinationLocation',
                          );
                          print(
                            'Date: $_tripPlanningDate, Time: $_tripPlanningTime',
                          );
                          print('Found ${_busRoutes.length} bus routes');
                        },
                        decoration: InputDecoration(
                          hintText: "Choose destination",
                          hintStyle: const TextStyle(color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          border: _border(),
                          enabledBorder: _border(),
                          focusedBorder: _border(),
                        ),
                      ),
                    ),

                    // Destination suggestions dropdown
                    if (_showDestinationSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isLoadingDestination
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : _destinationSuggestions.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No stops found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _destinationSuggestions.length,
                                itemBuilder: (context, index) {
                                  final stop = _destinationSuggestions[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      stop['stopName'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => _selectDestinationStop(stop),
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Swap icon
          GestureDetector(
            onTap: () {
              setState(() {
                isSwapped = !isSwapped;
                final temp = _startController.text;
                _startController.text = _destinationController.text;
                _destinationController.text = temp;
              });
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

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFBD2D01), width: 1.2),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _isLoadingMap
            ? Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading live location map...',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            : _mapErrorMessage != null
            ? Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'Map Error',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _mapErrorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMapFromApi,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  MapService.setMapController(controller);
                },
                initialCameraPosition: _initialCameraPosition,
                markers: _mapMarkers,
                polylines: _mapPolylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onTap: (LatLng position) {
                  print(
                    'Map tapped at: ${position.latitude}, ${position.longitude}',
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    // Use fetched bus routes instead of hardcoded data
    final itineraries = _busRoutes.map((route) {
      final routeData = route['route'] as Map<String, dynamic>;
      final shifts = route['shifts'] as List<dynamic>;

      return {
        "bus": routeData['routeNumber'] ?? "N/A",
        "routeName": routeData['routeName'] ?? "N/A",
        "travelTime": shifts.isNotEmpty
            ? shifts[0]['travelTime'] ?? "N/A"
            : "N/A",
        "departure": shifts.isNotEmpty
            ? shifts[0]['startTime'] ?? "N/A"
            : "N/A",
        "arrival": shifts.isNotEmpty ? shifts[0]['endTime'] ?? "N/A" : "N/A",
        "date": shifts.isNotEmpty ? shifts[0]['date'] ?? "N/A" : "N/A",
        "route": routeData['routeStops'] ?? [],
      };
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 247, 155, 51), // Updated color
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
            bottom: 8,
          ),
          child: Column(
            children: [
              // Title Row
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "Trip Itinerary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          showPanel = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Itinerary List with scrolling
              Expanded(
                child: _isLoadingBusRoutes
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Searching for bus routes...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : itineraries.isEmpty
                    ? const Center(
                        child: Text(
                          'No bus routes found for this trip',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: itineraries.length,
                        itemBuilder: (context, index) {
                          final item = itineraries[index];
                          final isExpanded = expandedIndex == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.directions_bus,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Route ${item["bus"] ?? ""}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            item["routeName"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if (!isExpanded) ...[
                                            Row(
                                              children: [
                                                const Text(
                                                  'Travel Time: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["travelTime"] ?? "-"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Date: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["date"] ?? "-"),
                                              ],
                                            ),
                                          ],
                                          if (isExpanded) ...[
                                            Row(
                                              children: [
                                                const Text(
                                                  'Departure Time: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["departure"] ?? "-"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Arrival Time: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["arrival"] ?? "-"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Travel Time: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["travelTime"] ?? "-"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Date: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(item["date"] ?? "-"),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Route:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if ((item["route"] as List?) !=
                                                null)
                                              Column(
                                                children: List.generate((item["route"] as List).length, (
                                                  i,
                                                ) {
                                                  final stops =
                                                      item["route"] as List;
                                                  final isFirst = i == 0;
                                                  final isLast =
                                                      i == stops.length - 1;
                                                  return Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center, // Center vertically
                                                        children: [
                                                          Container(
                                                            width:
                                                                24, // fixed width for alignment
                                                            alignment: Alignment
                                                                .center,
                                                            child: isFirst
                                                                ? const Icon(
                                                                    Icons
                                                                        .radio_button_checked,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 18,
                                                                  )
                                                                : isLast
                                                                ? const Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 18,
                                                                  )
                                                                : Container(
                                                                    width: 7,
                                                                    height: 7,
                                                                    decoration: const BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                stops[i],
                                                                style: const TextStyle(
                                                                  height: 1.2,
                                                                ), // Optional: tweak for better vertical alignment
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ), // Increased space between stops
                                                    ],
                                                  );
                                                }),
                                              ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                          255,
                                                          234,
                                                          118,
                                                          10,
                                                        ),
                                                    elevation: 4,
                                                    shadowColor: Colors.black
                                                        .withOpacity(0.6),
                                                    shape:
                                                        const StadiumBorder(), // <-- Makes it fully rounded
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      showPanel = false;
                                                    });
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/liveMap',
                                                      arguments: {
                                                        'passengerId':
                                                            widget.passengerId,
                                                      },
                                                    );
                                                  },
                                                  child: const Text(
                                                    "View Map",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        // Add to favorite logic
                                      },
                                    ),
                                  ],
                                ),
                                // Expand/Collapse Button
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        expandedIndex = isExpanded ? -1 : index;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Button
              Container(
                width: double.infinity,
                height: 42,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 189, 33, 16),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/placesAroundLocation',
                      arguments: {'passengerId': widget.passengerId},
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Places Around Colombo",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Color.fromARGB(255, 8, 8, 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // <<< ADD THESE FINAL CLOSINGS >>>
            ],
          ),
        );
      },
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
                    arguments: {'passengerId': widget.passengerId},
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
          // Close suggestions when tapping outside
          setState(() {
            _showStartSuggestions = false;
            _showDestinationSuggestions = false;
          });
        },
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildInputFields(),
                    _buildMap(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (showPanel)
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomPanel(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
