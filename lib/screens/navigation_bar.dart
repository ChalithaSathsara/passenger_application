/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passenger_app/screens/Home_screen.dart';
import 'package:passenger_app/screens/trip_planner_screen.dart';
import 'package:passenger_app/screens/live_map_scren.dart';
import 'package:passenger_app/screens/more_screen.dart';
import 'package:passenger_app/screens/favourite_screen.dart';
import 'package:passenger_app/screens/notification_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationBar(),
    );
  }
}

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TripPlannerScreen(),
    LiveMapScreen(),
    FavouriteScreen(),
    NotificationsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: _buildBottomNavBar(),
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
} */
