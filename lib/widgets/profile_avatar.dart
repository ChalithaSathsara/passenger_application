import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final double radius;

  const ProfileAvatar({
    Key? key,
    this.profileImageUrl,
    this.radius = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
          ? NetworkImage(profileImageUrl!)
          : null,
      child: (profileImageUrl == null || profileImageUrl!.isEmpty)
          ? const Icon(Icons.person, color: Color(0xFFFFA54F), size: 40)
          : null,
    );
  }
} 