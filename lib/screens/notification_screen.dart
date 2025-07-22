import 'package:flutter/material.dart';
import '../signalr_connection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final String passengerId;
  final Function(int) onTabSelected;
  const MainBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.passengerId,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = NotificationSignalRService.instance.unreadCount;
    NotificationSignalRService.instance.addUnreadListener(_onUnreadCount);
  }

  @override
  void dispose() {
    NotificationSignalRService.instance.removeUnreadListener(_onUnreadCount);
    super.dispose();
  }

  void _onUnreadCount(int count) {
    if (!mounted) return;
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          bool isSelected = index == widget.selectedIndex;

          Widget iconWidget = Icon(
            iconList[index],
            size: 22,
            color: isSelected ? Colors.white : const Color(0xFFBD2D01),
          );

          // Add badge for notifications icon
          if (iconList[index] == Icons.notifications && _unreadCount > 0) {
            iconWidget = Stack(
              clipBehavior: Clip.none,
              children: [
                iconWidget,
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          return GestureDetector(
            onTap: () => widget.onTabSelected(index),
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
              child: iconWidget,
            ),
          );
        }),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  final String passengerId;
  const NotificationsScreen({Key? key, required this.passengerId})
    : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 4;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    final notificationService = NotificationSignalRService.instance;
    notificationService.setPassengerId(widget.passengerId);
    _notifications = notificationService.notifications;
    _unreadCount = notificationService.unreadCount;
    notificationService.addNotificationListener(_onNotification);
    notificationService.addUnreadListener(_onUnreadCount);

    // Only mark as read after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationService.markAllAsRead();
    });
  }

  @override
  void dispose() {
    NotificationSignalRService.instance.removeNotificationListener(_onNotification);
    NotificationSignalRService.instance.removeUnreadListener(_onUnreadCount);
    super.dispose();
  }

  void _onNotification(Map<String, dynamic> notification) {
    setState(() {
      _notifications = NotificationSignalRService.instance.notifications;
    });
  }

  void _onUnreadCount(int count) {
    setState(() {
      _unreadCount = count;
    });
  }

  Future<Map<String, dynamic>?> fetchFeedbackDetails(String passengerId, String subject) async {
    final url = Uri.parse('https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Feedback');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> feedbacks = jsonDecode(response.body);
      final result = feedbacks.cast<Map<String, dynamic>>().firstWhere(
        (fb) => fb['passengerId'] == passengerId && fb['subject'] == subject,
        orElse: () => {},
      );
      return result.isNotEmpty ? result : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return _buildNotificationCard(item);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: 4,
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
        // Removed borderRadius
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
            "Notifications",
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

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final isAlert = item["type"] == "alert";
    final isFeedback = item["type"] == "feedback";
    if (isFeedback) {
      // Extract subject and passengerId from the notification message
      final subjectMatch = RegExp(r'has been replied: (.+)').firstMatch(item['message'] ?? '');
      final subject = subjectMatch != null ? subjectMatch.group(1) ?? '' : '';
      final passengerId = widget.passengerId;
      return FutureBuilder<Map<String, dynamic>?>(
        future: fetchFeedbackDetails(passengerId, subject),
        builder: (context, snapshot) {
          final feedback = snapshot.data;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 247, 155, 51),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.directions_bus, color: Colors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feedback Replied',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Subject: ${feedback?['subject'] ?? subject}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              if ((feedback?['reply'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Reply: ${feedback?['reply']}',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Date: ${feedback?['repliedTime']?.split('T')?.first ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Time: ${feedback?['repliedTime']?.split('T')?.last?.split('.')?.first ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: -18,
                  right: -10,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        NotificationSignalRService.instance.removeNotification(item);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 247, 155, 51),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 6), // Only bottom
          ),
        ],
      ),

      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + title/subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAlert ? Icons.warning : Icons.directions_bus,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item["subtitle"] ?? "",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date and time
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Date: ${item["date"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "Time: ${item["time"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Close button in top-right
          Positioned(
            top: -18,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.black),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  NotificationSignalRService.instance.removeNotification(item);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
