import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({Key? key}) : super(key: key);

  @override
  State<HelpAndSupport> createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  // Track which main section is expanded
  final List<bool> _isExpanded = [false, false, false, false];
  // Track which FAQ is expanded (null if none)
  int? _expandedFaq;

  // Detailed FAQ list
  final List<Map<String, String>> faqList = [
    {
      "question": "How do I log in to the Bus Finder Passenger App?",
      "answer":
          "On the login screen, enter your registered email and password. If you forget your password, tap 'Forgot Password?' to reset it.",
    },
    {
      "question": "How can I plan a trip using the Trip Planner?",
      "answer":
          "Go to the 'Trip Planner' section from the home screen or navigation bar. Enter your starting point and destination, then tap 'Plan Trip.' The app will suggest the best available routes and show you the buses you can take, including estimated times and transfers.",
    },
    {
      "question": "How can I view live bus locations?",
      "answer":
          "Tap the 'Live Map' section from the bottom navigation bar or 'View Map' button in trip planner . You’ll see real-time locations of all buses assigned to your network.",
    },
    {
      "question": "How can I report a technical issue or route problem?",
      "answer":
          "Use the 'Feedback' feature in the app. Fill in the details and submit; our support team will review and respond.",
    },
    {
      "question": "How do I update my profile information?",
      "answer":
          "Tap 'More' > 'Profile' to update your name, email, or profile picture. Tap 'Update' to save changes.",
    },
    {
      "question": "Why am I not receiving notifications?",
      "answer":
          "Ensure notifications are enabled in your device settings for the Bus Finder Staff App. Also, check your internet connection.",
    },

    {
      "question": "What should I do if the map is not loading?",
      "answer":
          "Check your internet connection and ensure location services are enabled. Try restarting the app if the issue persists.",
    },
    {
      "question": "How can I add a place or bus to my favourites?",
      "answer":
          "When viewing a place or bus details, tap the star or 'Add to Favourites' button. The item will be saved to your Favourites list for quick access later.",
    },
    {
      "question": "Where can I find my favourite places and buses?",
      "answer":
          "Go to the 'Favourites' section from the home screen or navigation bar. Here you’ll see all your saved places and buses for easy access and trip planning.",
    },
    {
      "question": "How do I contact support?",
      "answer":
          "Go to 'Help & Support' > 'Contact Support' to call or email our support team directly from the app.",
    },

    {
      "question": "How can I visit places around my location?",
      "answer":
          "Open the 'Trip Planner' section and tap the 'Places Around Location' button. The app will display a list and map of nearby points of interest, such as bus stops, restaurants, and landmarks, based on your current location. Tap any place to view more details or get directions.",
    },
  ];

  final String appGuideText = """
Welcome to the Bus Finder Passenger App! This guide will help you make the most of your travel experience.

🔸 Home:
Your starting point for quick access to all app features, including trip planning, live map, and recent notifications.

🔸 Trip Planner:
Plan your journey by entering your starting point and destination. The app will suggest the best available routes, show you which buses to take, and provide estimated travel times and transfers.

🔸 Live Map:
View real-time locations of buses on the map. You can track buses along their routes and see estimated arrival times at your stop.

🔸 Places Around Location:
Find nearby points of interest such as bus stops, restaurants, and landmarks. Access this feature from the Trip Planner by tapping the 'Places Around Location' button.

🔸 Favourites:
Save your most-used places and buses for quick access. Tap the star icon on any place or bus to add it to your Favourites. Access all your favourites from the 'Favourites' section in the app.

🔸 Notifications:
Stay updated with important alerts, such as bus delays, route changes, and special announcements.

🔸 Profile Management:
Update your personal information, change your password, and manage your account settings from the Profile section.

🔸 Help & Support:
Access FAQs, troubleshooting tips, and contact support for any assistance you need.

The Bus Finder Passenger App is designed to make your daily commute easier, more efficient, and more informed.
""";

  final List<Map<String, String>> troubleshootingList = [
    {
      "title": "Forgot Password",
      "description": "Reset your password using email verification",
      "action":
          "Go to Login → Forgot Password → Enter Email → Check Email → Reset Password",
    },
    {
      "title": "Update Profile Details",
      "description": "Modify your personal information and profile picture",
      "action": "More → Profile → Edit Fields → Update → Save Changes",
    },
    {
      "title": "App Not Loading",
      "description": "Troubleshoot app startup issues",
      "action":
          "Check internet connection → Restart app → Clear cache → Reinstall if needed",
    },
    {
      "title": "Map Not Showing",
      "description": "Fix map display issues",
      "action":
          "Enable location services → Check GPS → Refresh map → Restart app",
    },
    {
      "title": "Notifications Not Working",
      "description": "Enable app notifications",
      "action": "Settings → Apps → Bus Finder → Notifications → Enable",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.1, 0.5, 0.9, 1.0],
            colors: [
              Color(0xFFBD2D01),
              Color(0xFFCF4602),
              Color(0xFFF67F00),
              Color(0xFFCF4602),
              Color(0xFFBD2D01),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildExpansionList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 16, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFBD2D01),
            Color(0xFFCF4602),
            Color(0xFFF67F00),
            Color(0xFFCF4602),
            Color(0xFFBD2D01),
          ],
        ),
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Help & Support",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionList() {
    return Column(
      children: [
        // FAQ Section with expandable questions
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded[0],
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[0] = expanded;
                  if (!expanded) _expandedFaq = null;
                });
              },
              leading: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: const Icon(
                  Icons.question_answer,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Color(0xFFBD2D01),
                        Color(0xFFCF4602),
                        Color(0xFFF67F00),
                        Color(0xFFCF4602),
                        Color(0xFFBD2D01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Text(
                  "FAQs",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: Icon(
                  _isExpanded[0]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              children: [
                Column(
                  children: List.generate(faqList.length, (i) {
                    final q = faqList[i];
                    final isFaqExpanded = _expandedFaq == i;
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                        left: 8,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isFaqExpanded
                            ? const Color(0xFFFBE9E7)
                            : Colors.white,
                        border: Border.all(
                          color: const Color(0xFFCF4602),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              q["question"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFCF4602),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFaqExpanded ? Icons.remove : Icons.add,
                                color: const Color(0xFFCF4602),
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandedFaq = isFaqExpanded ? null : i;
                                });
                              },
                            ),
                          ),
                          if (isFaqExpanded)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 12,
                              ),
                              child: Text(
                                q["answer"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        // App Guide Section
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded[1],
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[1] = expanded;
                });
              },
              leading: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: const Icon(Icons.menu, size: 28, color: Colors.white),
              ),
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Color(0xFFBD2D01),
                        Color(0xFFCF4602),
                        Color(0xFFF67F00),
                        Color(0xFFCF4602),
                        Color(0xFFBD2D01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Text(
                  "App Guide",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: Icon(
                  _isExpanded[1]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'Welcome to the Bus Finder Passenger App! This guide will help you make the most of your travel experience.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Home:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'Your starting point for quick access to all app features, including trip planning, live map, and recent notifications.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Trip Planner:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'Plan your journey by entering your starting point and destination. The app will suggest the best available routes, show you which buses to take, and provide estimated travel times and transfers.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Live Map:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'View real-time locations of buses on the map. You can track buses along their routes and see estimated arrival times at your stop.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Places Around Location:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              "Find nearby points of interest such as bus stops, restaurants, and landmarks. Access this feature from the Trip Planner by tapping the 'Places Around Location' button.\n\n",
                        ),
                        const TextSpan(
                          text: '🔸 Favourites:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              "Save your most-used places and buses for quick access. Tap the star icon on any place or bus to add it to your Favourites. Access all your favourites from the 'Favourites' section in the app.\n\n",
                        ),
                        const TextSpan(
                          text: '🔸 Notifications:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'Stay updated with important alerts, such as bus delays, route changes, and special announcements.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Profile Management:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'Update your personal information, change your password, and manage your account settings from the Profile section.\n\n',
                        ),
                        const TextSpan(
                          text: '🔸 Help & Support:\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'Access FAQs, troubleshooting tips, and contact support for any assistance you need.\n\n',
                        ),
                        const TextSpan(
                          text:
                              'The Bus Finder Passenger App is designed to make your daily commute easier, more efficient, and more informed.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Troubleshooting Section
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded[2],
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[2] = expanded;
                });
              },
              leading: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: const Icon(
                  Icons.gps_fixed,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Color(0xFFBD2D01),
                        Color(0xFFCF4602),
                        Color(0xFFF67F00),
                        Color(0xFFCF4602),
                        Color(0xFFBD2D01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Text(
                  "Troubleshooting",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: Icon(
                  _isExpanded[2]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              children: [
                Column(
                  children: troubleshootingList.map((item) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBE9E7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFCF4602),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCF4602),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["description"]!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["action"]!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFCF4602),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        // Contact Support Section
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded[3],
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[3] = expanded;
                });
              },
              leading: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: const Icon(Icons.phone, size: 28, color: Colors.white),
              ),
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Color(0xFFBD2D01),
                        Color(0xFFCF4602),
                        Color(0xFFF67F00),
                        Color(0xFFCF4602),
                        Color(0xFFBD2D01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: const Text(
                  "Contact Support",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              trailing: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFBD2D01),
                    Color(0xFFCF4602),
                    Color(0xFFF67F00),
                    Color(0xFFCF4602),
                    Color(0xFFBD2D01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(Rect.fromLTWH(0, 0, 24, 24)),
                child: Icon(
                  _isExpanded[3]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You can reach our support team via:",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      GestureDetector(
                        onTap: _launchPhone,
                        child: Row(
                          children: const [
                            Icon(Icons.phone, color: Color(0xFFCF4602)),
                            SizedBox(width: 10),
                            Text(
                              "072 640 7655",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFCF4602),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Email
                      GestureDetector(
                        onTap: _launchEmail,
                        child: Row(
                          children: const [
                            Icon(Icons.email, color: Color(0xFFCF4602)),
                            SizedBox(width: 10),
                            Text(
                              "busfindersl@gmail.com",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFCF4602),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Our support team is available to help you with any technical issues, app-related questions, or general inquiries. We typically respond within 24 hours.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Phone and email launch logic
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '0726407655');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No phone app found on your device')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error launching phone: $e')));
      }
    }
  }

  Future<void> _launchEmail() async {
    final Uri mailtoUri = Uri(
      scheme: 'mailto',
      path: 'busfindersl@gmail.com',
      query: 'subject=Bus Finder Staff App Support&body=Hello, I need help with the Bus Finder Staff App.',
    );
    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No email app found. Please install an email app.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching email: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}