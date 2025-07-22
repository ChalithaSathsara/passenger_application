import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final String passengerId;
  final String? initialFullName;
  const HomeScreen({Key? key, required this.passengerId, this.initialFullName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String fullName = "";
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialFullName != null && widget.initialFullName!.isNotEmpty) {
      fullName = widget.initialFullName!;
      _isLoadingName = false;
    } else {
      _fetchPassengerName();
    }
  }

  Future<void> _fetchPassengerName() async {
    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/${widget.passengerId}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        setState(() {
          fullName = (firstName + ' ' + lastName).trim();
          _isLoadingName = false;
        });
      } else {
        print('Failed to fetch passenger data: ${response.statusCode}');
        setState(() {
          _isLoadingName = false;
        });
      }
    } catch (e) {
      print('Error fetching passenger data: $e');
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 247, 155, 51),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _isLoadingName
                ? const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(
                    'Hi $fullName,\nGood Afternoon!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageCard(
    String label,
    String asset, {
    bool showFavorite = false,
    VoidCallback? onTap,
  }) {
    final double cardHeight = MediaQuery.of(context).size.width > 600 ? 140 : 100;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 247, 155, 51),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(asset, height: 50),
            ),
            if (showFavorite)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildImageCard(
              "Buses",
              "assets/images/RedBus.png",
              showFavorite: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/favourites',
                  arguments: {
                    'passengerId': widget.passengerId,
                    'showBuses': true,
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildImageCard(
              "Places",
              "assets/images/Places.png",
              showFavorite: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/favourites',
                  arguments: {
                    'passengerId': widget.passengerId,
                    'showBuses': false,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade400, // Ash/light gray border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(
              "assets/images/GoogleMap.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGradientButtonSmall("Plan Trip"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBD2D01),
            Color(0xFFCF4602),
            Color(0xFFF67F00),
            Color(0xFFCF4602),
            Color(0xFFBD2D01),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButtonSmall(String label) {
    return Container(
      width: 180,
      height: 38,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 138, 20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (label == "Plan Trip") {
            Navigator.pushNamed(
              context,
              '/tripPlanner',
              arguments: {'passengerId': widget.passengerId},
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 155, 51),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildSectionLabel("Favorites"),
                      _buildFavorites(),
                      _buildMapSection(),
                    ],
                  ),
                ),
              ),
            ),
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
      ),
    );
  }
}
