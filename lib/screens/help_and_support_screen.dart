import 'package:flutter/material.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({Key? key}) : super(key: key);

  @override
  State<HelpAndSupport> createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  final List<bool> _isExpanded = [false, false, false, false];

  final items = [
    {
      "title": "FAQs",
      "icon": Icons.question_answer,
      "content":
          "Q: How do I reset my password?\nA: Go to settings > reset password.\n\nQ: How do I contact support?\nA: Use the Contact Support section below.",
    },
    {
      "title": "App Guide",
      "icon": Icons.menu,
      "content":
          "The App Guide provides detailed instructions on how to navigate and use all features effectively.",
    },
    {
      "title": "Troubleshooting",
      "icon": Icons.gps_fixed,
      "content":
          "If you encounter problems:\n1. Restart the app.\n2. Check your internet connection.\n3. Reinstall if needed.",
    },
    {
      "title": "Contact Support",
      "icon": Icons.phone,
      "content":
          "You can reach our support team at support@example.com or call 123-456-7890. We are available 24/7.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFBD2D01),
              Color(0xFFCF4602),
              Color(0xFFF67F00),
              Color(0xFFCF4602),
              Color(0xFFBD2D01),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Container(
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
              initiallyExpanded: _isExpanded[index],
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded[index] = expanded;
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
                child: Icon(
                  item["icon"] as IconData,
                  size: 28,
                  color: Colors.white, // Must set to white for gradient mask
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
                child: Text(
                  item["title"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white, // Must be white for gradient mask
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
                  _isExpanded[index]
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                  color: Colors.white, // white for mask
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    item["content"] as String,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
