import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFA54F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Hi John Rubik,\nGood Afternoon!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.orange.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFFFF6600), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Central Bus Stand - Colombo",
          border: InputBorder.none,
          icon: Icon(
            Icons.near_me,
            color: Color.fromARGB(255, 8, 8, 8),
            size: 20,
          ),
          suffixIcon: Icon(Icons.search, color: Color(0xFFFF6600)),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA54F),
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
                  color: Colors.white, // Updated to white
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

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          _buildImageCard(
            "Buses",
            "assets/images/RedBus.png",
            onTap: () {
              Navigator.pushNamed(context, '/suggest');
            },
          ),
          _buildImageCard(
            "Places",
            "assets/images/Places.png",
            onTap: () {
              Navigator.pushNamed(context, '/suggest');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          _buildImageCard(
            "Buses",
            "assets/images/RedBus.png",
            showFavorite: true,
            onTap: () {
              Navigator.pushNamed(context, '/RecoverPassword');
            },
          ),
          _buildImageCard(
            "Places",
            "assets/images/Places.png",
            showFavorite: true,
            onTap: () {
              Navigator.pushNamed(context, '/RecoverPassword');
            },
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGradientButtonSmall("View Live Map"),
                  const SizedBox(height: 8),
                  _buildGradientButtonSmall("Plan Trip"),
                ],
              ),
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
        onPressed: () {
          if (label == "Plan Trip") {
            Navigator.pushNamed(context, '/tripPlanner');
          } else if (label == "View Live Map") {
            //Navigator.pushNamed(context, '/liveMap');
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
            fontSize: 14,
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
                  Navigator.pushNamed(context, '/RecoverPassword');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/RecoverPassword');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/RecoverPassword');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/RecoverPassword');
                  break;
                case 4:
                  Navigator.pushNamed(context, '/RecoverPassword');
                  break;
                case 5:
                  Navigator.pushNamed(context, '/RecoverPassword');
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
      backgroundColor: const Color(0xFFFFA54F),
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
                      _buildSearchBar(),
                      _buildSectionLabel("Suggestion"),
                      _buildSuggestions(),
                      const SizedBox(height: 10),
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
