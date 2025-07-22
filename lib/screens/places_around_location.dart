import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marquee/marquee.dart';

class PlacesAroundLocationScreen extends StatefulWidget {
  const PlacesAroundLocationScreen({super.key});

  @override
  State<PlacesAroundLocationScreen> createState() => _PlacesAroundLocationScreenState();
}

class _PlacesAroundLocationScreenState extends State<PlacesAroundLocationScreen> {
  int _selectedIndex = 1;
  String? destination;
  String? passengerId;
  List<dynamic> places = [];
  bool isLoading = true;
  String? errorMessage;
  Set<int> favoriteIndices = {};
  Set<String> favoritePlaceNames = {};
  Map<int, bool> isFavoriteLoading = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    destination = args != null && args['destination'] != null ? args['destination'] as String : null;
    passengerId = args != null && args['passengerId'] != null ? args['passengerId'] as String : null;
    if (destination != null && destination!.isNotEmpty) {
      _fetchPlacesAndFavorites(destination!);
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'No destination provided.';
      });
    }
  }

  Future<void> _fetchPlacesAndFavorites(String name) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Fetch places
      final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Place/search/google/${Uri.encodeComponent(name)}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        places = data;
        // Fetch favorites if passengerId is available
        if (passengerId != null && passengerId!.isNotEmpty) {
          final favUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/$passengerId/favorite-places';
          final favResponse = await http.get(Uri.parse(favUrl));
          if (favResponse.statusCode == 200) {
            final favData = jsonDecode(favResponse.body);
            final List<dynamic> favList = favData['favoritePlaces'] ?? [];
            // Extract place names from the favorite places list
            favoritePlaceNames = favList.map((e) {
              if (e is Map<String, dynamic>) {
                return e['placeName']?.toString() ?? '';
              } else {
                return e.toString();
              }
            }).where((name) => name.isNotEmpty).toSet();
            // Pre-select favorite indices
            favoriteIndices = {};
            for (int i = 0; i < places.length; i++) {
              final String placeName = places[i]['placeName'] ?? '';
              if (favoritePlaceNames.contains(placeName)) {
                favoriteIndices.add(i);
              }
            }
          }
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch places. (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred while fetching places.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color.fromARGB(255, 247, 155, 51),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 24,
              child: Marquee(
                text: 'Places Around ${destination ?? '...'}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                blankSpace: 40,
                velocity: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (places.isEmpty) {
      return const Center(
        child: Text(
          'No places found for this destination.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return _buildPlaceGrid();
  }

  Widget _buildPlaceGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        final String placeName = place['placeName'] ?? 'Unknown Place';
        final String? imageUrl = place['locationImage'];
        final bool isFavorite = favoriteIndices.contains(index);
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Stack(
                      children: [
                        imageUrl != null && imageUrl.isNotEmpty
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 247, 155, 51), // prominent app color
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
                                    icon: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : Colors.white,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      if (passengerId == null || passengerId!.isEmpty) return;
                                      setState(() {
                                        isFavoriteLoading[index] = true;
                                      });
                                      final placeNameForApi = placeName;
                                      final double latitude = place['latitude']?.toDouble() ?? 0.0;
                                      final double longitude = place['longitude']?.toDouble() ?? 0.0;
                                      final String? locationImage = place['locationImage'];
                                      try {
                                        if (!isFavorite) {
                                          // Add to favorites (POST)
                                          final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/$passengerId/favorite-places';
                                          final requestBody = {
                                            'placeName': placeNameForApi,
                                            'latitude': latitude,
                                            'longitude': longitude,
                                            'locationImage': locationImage ?? '',
                                          };
                                          final response = await http.post(
                                            Uri.parse(url),
                                            headers: {'Content-Type': 'application/json'},
                                            body: jsonEncode(requestBody),
                                          );
                                          if (response.statusCode == 200 || response.statusCode == 201) {
                                            setState(() {
                                              favoriteIndices.add(index);
                                              favoritePlaceNames.add(placeNameForApi);
                                            });
                                          }
                                        } else {
                                          // Remove from favorites (DELETE)
                                          final url = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/$passengerId/favorite-places';
                                          final requestBody = {
                                            'placeName': placeNameForApi,
                                            'latitude': latitude,
                                            'longitude': longitude,
                                          };
                                          final response = await http.delete(
                                            Uri.parse(url),
                                            headers: {'Content-Type': 'application/json'},
                                            body: jsonEncode(requestBody),
                                          );
                                          if (response.statusCode == 200 || response.statusCode == 204) {
                                            setState(() {
                                              favoriteIndices.remove(index);
                                              favoritePlaceNames.remove(placeNameForApi);
                                            });
                                          }
                                        }
                                      } catch (e) {
                                        // Optionally show error
                                      } finally {
                                        setState(() {
                                          isFavoriteLoading[index] = false;
                                        });
                                      }
                                    },
                                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
          ],
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
                    arguments: {'passengerId': passengerId},
                  );
                  break;
                case 1:
                  Navigator.pushReplacementNamed(
                    context,
                    '/tripPlanner',
                    arguments: {'passengerId': passengerId},
                  );
                  break;
                case 2:
                  Navigator.pushReplacementNamed(
                    context,
                    '/liveMap',
                    arguments: {'passengerId': passengerId},
                  );
                  break;
                case 3:
                  Navigator.pushReplacementNamed(
                    context,
                    '/favourites',
                    arguments: {'passengerId': passengerId, 'showBuses': true},
                  );
                  break;
                case 4:
                  Navigator.pushReplacementNamed(
                    context,
                    '/notifications',
                    arguments: {'passengerId': passengerId},
                  );
                  break;
                case 5:
                  Navigator.pushReplacementNamed(
                    context,
                    '/more',
                    arguments: {'passengerId': passengerId},
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
}
