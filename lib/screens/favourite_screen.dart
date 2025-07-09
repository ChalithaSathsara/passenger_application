import 'package:flutter/material.dart';

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
  bool showBuses = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    if (widget.initialShowBuses != null) {
      showBuses = widget.initialShowBuses!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check arguments every time dependencies change
    final args = ModalRoute.of(context)?.settings.arguments;
    print('FavouriteScreen - Arguments received: $args');
    if (args != null &&
        args is Map<String, dynamic> &&
        args['showBuses'] != null) {
      final newShowBuses = args['showBuses'] as bool;
      print(
        'FavouriteScreen - showBuses value: $newShowBuses, current: $showBuses',
      );
      if (mounted) {
        setState(() {
          showBuses = newShowBuses;
        });
      }
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

  // Keep track of expanded buses
  Set<int> expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildToggleTabs(),
            Expanded(child: showBuses ? _buildBusList() : _buildPlaceGrid()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
                  showBuses = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: showBuses
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
                  color: showBuses ? null : Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Buses",
                  style: TextStyle(
                    color: showBuses ? Colors.white : Colors.black,
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
                  showBuses = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: !showBuses
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
                  color: !showBuses ? null : Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Places",
                  style: TextStyle(
                    color: !showBuses ? Colors.white : Colors.black,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: busList.length,
      itemBuilder: (context, index) {
        final bus = busList[index];
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
                  "No. ${bus["number"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Travel Time: ${bus["time"]}"),
                    Text("Distance: ${bus["distance"]}"),
                  ],
                ),
                trailing: Transform.translate(
                  offset: const Offset(
                    9,
                    30,
                  ), // Moves 5 pixels right and 5 pixels up
                  child: const Icon(Icons.expand_more),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      "More details about Bus No. ${bus["number"]} can be shown here.",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.red),
                onPressed: () {
                  // handle favorite toggle if needed
                },
              ),
            ),
          ],
        );
      },
    );
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Image.asset(places[index], fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 234, 118, 10),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Gangarama Temple",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.red),
                onPressed: () {
                  // handle favorite toggle if needed
                },
              ),
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
}
