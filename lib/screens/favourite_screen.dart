import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marquee/marquee.dart';
import 'notification_screen.dart';

class FavouriteScreen extends StatefulWidget {
  final String passengerId;
  final bool? initialShowBuses;
  const FavouriteScreen({
    Key? key,
    required this.passengerId,
    this.initialShowBuses,
  }) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // Remove showBuses field and use a getter
  int _selectedIndex = 3;

  List<Map<String, dynamic>> favoriteBusRoutes = [];
  bool isLoadingBuses = false;
  Map<int, bool> isBusFavoriteLoading = {};

  List<Map<String, dynamic>> favoritePlaces = [];
  bool isLoadingPlaces = false;
  Map<int, bool> isFavoriteLoading = {};

  // Keep track of expanded buses
  Set<int> expandedIndices = {};

  bool? _lastShowBuses;
  bool _showBusesTab = true;

  bool get showBuses {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && args['showBuses'] != null) {
      return args['showBuses'] as bool;
    }
    if (widget.initialShowBuses != null) {
      return widget.initialShowBuses!;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // The showBuses getter will handle the initial fetch
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final newShowBuses = showBuses;
  //   if (_lastShowBuses != newShowBuses) {
  //     _lastShowBuses = newShowBuses;
  //     _showBusesTab = newShowBuses;
  //     if (_showBusesTab) {
  //       _fetchFavoriteBusRoutes();
  //     } else {
  //       _fetchFavoritePlaces();
  //     }
  //     setState(() {});
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lastShowBuses == null) {
      _lastShowBuses = showBuses;
      _showBusesTab = _lastShowBuses!;
      if (_showBusesTab) {
        _fetchFavoriteBusRoutes();
      } else {
        _fetchFavoritePlaces();
      }
    }
  }


  Future<void> _fetchFavoritePlaces() async {
    setState(() {
      isLoadingPlaces = true;
    });
    try {
      print('[FavouriteScreen] Fetching favorite places for passengerId: \'${widget.passengerId}\'');
      final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/${widget.passengerId}/favorite-places';
      final response = await http.get(Uri.parse(url));
      print('[FavouriteScreen] GET $url => status: \'${response.statusCode}\', body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favList = data['favoritePlaces'] ?? [];
        print('[FavouriteScreen] Parsed favoritePlaces: $favList');
        // The API now returns full place objects with name, coordinates, and image
        favoritePlaces = favList.map<Map<String, dynamic>>((place) {
          if (place is Map<String, dynamic>) {
            return place; // Already in the correct format
          } else {
            // Fallback for string-only format (backward compatibility)
            return {
              'placeName': place.toString(),
              'locationImage': 'assets/images/GoogleMap.png',
              'latitude': 0.0,
              'longitude': 0.0,
            };
          }
        }).toList();
        if (favoritePlaces.isEmpty) {
          print('[FavouriteScreen] No favorite places found for this user.');
        }
      } else {
        favoritePlaces = [];
        print('[FavouriteScreen] Non-200 response, setting favoritePlaces to empty.');
      }
    } catch (e) {
      favoritePlaces = [];
      print('[FavouriteScreen] Error fetching favorite places: $e');
    }
    setState(() {
      isLoadingPlaces = false;
    });
  }

  Future<void> _fetchFavoriteBusRoutes() async {
    setState(() {
      isLoadingBuses = true;
    });
    try {
      final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/${widget.passengerId}/favorite-routes';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> routeNumbers = data['favoriteRoutes'] ?? [];
        List<Map<String, dynamic>> routes = [];
        for (final routeNumber in routeNumbers) {
          final routeUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/BusRoute/$routeNumber';
          final routeResp = await http.get(Uri.parse(routeUrl));
          if (routeResp.statusCode == 200) {
            final routeData = jsonDecode(routeResp.body);
            routes.add(routeData);
          }
        }
        setState(() {
          favoriteBusRoutes = routes;
        });
      } else {
        setState(() {
          favoriteBusRoutes = [];
        });
      }
    } catch (e) {
      setState(() {
        favoriteBusRoutes = [];
      });
    }
    setState(() {
      isLoadingBuses = false;
    });
  }

  Future<void> _removeFavoriteBusRoute(String routeNumber, int index) async {
    setState(() {
      isBusFavoriteLoading[index] = true;
    });
    try {
      final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/${widget.passengerId}/favorite-routes/$routeNumber';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          favoriteBusRoutes.removeAt(index);
        });
      }
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() {
        isBusFavoriteLoading[index] = false;
      });
    }
  }

  // Sample dynamic data
  final List<Map<String, String>> busList = [
    {"number": "05", "time": "Around 2.5 hours", "distance": "93.4km"},
    {"number": "EX4-6", "time": "Around 2 hours 10min", "distance": "102km"},
    {"number": "34/1", "time": "Around 2.5 hours", "distance": "112.4km"},
  ];

  final List<String> places = [
    "assets/images/GoogleMap.png",
    "assets/images/GoogleMap.png",
    "assets/images/GoogleMap.png",
    "assets/images/GoogleMap.png",
    "assets/images/GoogleMap.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildToggleTabs(),
            Expanded(child: _showBusesTab ? _buildBusList() : _buildPlaceGrid()),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: _selectedIndex,
        passengerId: widget.passengerId,
        onTabSelected: (index) {
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 247, 155, 51),
        // Removed borderRadius to make it flat
      ),
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
            "Favourites",
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

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // Buses Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showBusesTab = true;
                  _fetchFavoriteBusRoutes();
                });
                Navigator.pushReplacementNamed(
                  context,
                  '/favourites',
                  arguments: {
                    'passengerId': widget.passengerId,
                    'showBuses': true,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: _showBusesTab
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 230, 119, 29),
                            Color.fromARGB(255, 227, 121, 34),
                            Color.fromARGB(255, 214, 113, 30),
                            Color.fromARGB(255, 211, 95, 12),
                            Color.fromARGB(255, 203, 51, 5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 234, 118, 10),
                    width: 1.2,
                  ),
                  color: _showBusesTab ? null : Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Buses",
                  style: TextStyle(
                    color: _showBusesTab ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12), // Space between buttons
          // Places Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showBusesTab = false;
                  _fetchFavoritePlaces();
                });
                Navigator.pushReplacementNamed(
                  context,
                  '/favourites',
                  arguments: {
                    'passengerId': widget.passengerId,
                    'showBuses': false,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: !_showBusesTab
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 230, 119, 29),
                            Color.fromARGB(255, 227, 121, 34),
                            Color.fromARGB(255, 214, 113, 30),
                            Color.fromARGB(255, 211, 95, 12),
                            Color.fromARGB(255, 203, 51, 5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 234, 118, 10),
                    width: 1.2,
                  ),
                  color: !_showBusesTab ? null : Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Places",
                  style: TextStyle(
                    color: !_showBusesTab ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusList() {
    if (isLoadingBuses) {
      return const Center(child: CircularProgressIndicator());
    }
    if (favoriteBusRoutes.isEmpty) {
      return const Center(
        child: Text(
          'No favorite bus routes yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteBusRoutes.length,
      itemBuilder: (context, index) {
        final route = favoriteBusRoutes[index];
        final String routeNumber = route['routeNumber'] ?? 'Unknown';
        final String routeName = route['routeName'] ?? '';
        final List<dynamic> routeStops = route['routeStops'] ?? [];
        final double routeDistance = (route['routeDistance'] ?? 0.0).toDouble();
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: const Icon(Icons.directions_bus, color: Colors.black),
                title: Text(
                  "No. $routeNumber",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routeName),
                    Text("Distance: ${routeDistance.toStringAsFixed(2)} km"),
                  ],
                ),
                trailing: Transform.translate(
                  offset: const Offset(9, 30),
                  child: const Icon(Icons.expand_more),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Route Stops:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(routeStops.length, (i) {
                          final isFirst = i == 0;
                          final isLast = i == routeStops.length - 1;
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: isFirst
                                        ? const Icon(Icons.radio_button_checked, color: Colors.red, size: 18)
                                        : isLast
                                            ? const Icon(Icons.location_on, color: Colors.red, size: 18)
                                            : Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        routeStops[i],
                                        style: const TextStyle(height: 1.2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: isBusFavoriteLoading[index] == true
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavoriteBusRoute(routeNumber, index),
                      tooltip: 'Remove from favorites',
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceGrid() {
    if (isLoadingPlaces) {
      return const Center(child: CircularProgressIndicator());
    }
    if (favoritePlaces.isEmpty) {
      return const Center(
        child: Text(
          'No favorite places yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: favoritePlaces.length,
      itemBuilder: (context, index) {
        final place = favoritePlaces[index];
        final String placeName = place['placeName'] ?? 'Unknown Place';
        final String? imageUrl = place['locationImage'];
        final bool isFavorite = true;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? SizedBox.expand(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/GoogleMap.png', fit: BoxFit.cover),
                              ),
                            )
                          : SizedBox.expand(
                              child: Image.asset('assets/images/GoogleMap.png', fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 234, 118, 10),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 16, // Adjust as needed
                      child: Marquee(
                        text: placeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        blankSpace: 20.0,
                        velocity: 30.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 155, 51),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: isFavoriteLoading[index] == true
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          print('[FavouriteScreen] Attempting to remove favorite: $placeName');
                          setState(() {
                            isFavoriteLoading[index] = true;
                          });
                          try {
                            final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/${widget.passengerId}/favorite-places';
                            final double latitude = place['latitude']?.toDouble() ?? 0.0;
                            final double longitude = place['longitude']?.toDouble() ?? 0.0;
                            final requestBody = {
                              'placeName': placeName,
                              'latitude': latitude,
                              'longitude': longitude,
                            };
                            print('[FavouriteScreen] DELETE $url with body: $requestBody');
                            final response = await http.delete(
                              Uri.parse(url),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(requestBody),
                            );
                            print('[FavouriteScreen] DELETE response: status=${response.statusCode}, body=${response.body}');
                            if (response.statusCode == 200 || response.statusCode == 204) {
                              setState(() {
                                favoritePlaces.removeAt(index);
                              });
                              print('[FavouriteScreen] Removed $placeName from UI');
                            }
                          } catch (e) {
                            // Optionally show error
                            print('[FavouriteScreen] Error removing favorite: $e');
                          } finally {
                            setState(() {
                              isFavoriteLoading[index] = false;
                            });
                          }
                        },
                        tooltip: 'Remove from favorites',
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
