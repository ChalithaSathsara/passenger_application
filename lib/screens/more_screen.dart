import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_screen.dart';

class MoreScreen extends StatefulWidget {
  final String passengerId;
  const MoreScreen({Key? key, required this.passengerId}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String userName = "";
  String? profileImageUrl;
  int _selectedIndex = 5;

  @override
  void initState() {
    super.initState();
    _fetchPassengerNameAndImage();
  }

  Future<void> _fetchPassengerNameAndImage() async {
    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/${widget.passengerId}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        setState(() {
          userName = (firstName + ' ' + lastName).trim();
          profileImageUrl = data['profileImageUrl'];
        });
      } else {
        print('Failed to fetch passenger data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching passenger data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFA54F), // Keep orange behind
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: SingleChildScrollView(child: _buildContent())),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Color.fromARGB(255, 247, 155, 51),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {'passengerId': widget.passengerId},
                  );
                },
              ),
            ],
          ),
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color.fromARGB(255, 5, 5, 5),
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl!)
                : null,
            child: profileImageUrl == null
                ? const Icon(Icons.person, color: Color(0xFFFFA54F), size: 40)
                : null,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: Text(
              userName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30), // Rounded top corners
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildButton(
            icon: Icons.person,
            text: "Profile",
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'passengerId': widget.passengerId},
              );
            },
          ),
          const SizedBox(height: 20),
          _buildButton(
            icon: Icons.feedback,
            text: "Feedback",
            onTap: () {
              Navigator.pushNamed(
                context,
                '/feedback',
                arguments: {'passengerId': widget.passengerId},
              );
            },
          ),
          const SizedBox(height: 20),
          _buildButton(
            icon: Icons.support,
            text: "Help & Support",
            onTap: () {
              Navigator.pushNamed(context, '/helpAndSupport');
            },
          ),
          const SizedBox(height: 20),
          _buildButton(
            icon: Icons.info,
            text: "About Us",
            onTap: () {
              Navigator.pushNamed(context, '/aboutUs');
            },
          ),
          const SizedBox(height: 20),
          _buildButton(
            iconWidget: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159), // 180 degrees flip
              child: Icon(Icons.logout, color: Colors.white),
            ),
            text: "Log Out",
            onTap: () {
              Navigator.pushNamed(context, "/login");
            },
            showArrow: false,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildButton({
    Widget? iconWidget,
    IconData? icon,
    required String text,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
        child: Row(
          children: [
            iconWidget ?? Icon(icon, color: Colors.white),

            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}