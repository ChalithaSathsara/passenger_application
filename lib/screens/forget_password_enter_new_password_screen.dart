import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Widget _buildAppBar() {
    return Container(
      width: double.infinity, // make sure it spans the whole width
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: const [
          BackButton(color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Reset Password",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingText() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFFBD2D01),
            Color(0xFFCF4602),
            Color(0xFFF67F00),
            Color(0xFFCF4602),
            Color(0xFFBD2D01),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds);
      },
      child: const Text(
        "Enter New Password",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Needed for ShaderMask
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      "Your new password must be different from the previous used password.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 120, 118, 118)),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFFF6600), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFFE5D0),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Color(0xFFFF6600),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Color(0xFFFF6600),
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity, // Match input field width
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 230, 119, 29),
              Color.fromARGB(255, 227, 121, 34),
              Color.fromARGB(255, 214, 113, 30),
              Color.fromARGB(255, 211, 95, 12),
              Color.fromARGB(255, 203, 51, 5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _resetPassword();
            // Handle password reset action here
          },
          child: const Text(
            "Continue",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeadingText(),
          const SizedBox(height: 8),
          _buildInstructionText(),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newPasswordController,
            hintText: "New Password",
            isVisible: _isNewPasswordVisible,
            onToggle: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hintText: "Confirm Password",
            isVisible: _isConfirmPasswordVisible,
            onToggle: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildResetButton(),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final url =
        'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/reset-password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': widget.email, 'NewPassword': newPassword}),
      );

      print('API URL: $url');
      print(
        'API Request Body: ${jsonEncode({'Email': widget.email, 'NewPassword': newPassword})}',
      );
      print('API Status Code: ${response.statusCode}');
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Password reset successful! Please log in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final body = jsonDecode(response.body);
        String errorMsg =
            body['message'] ?? body['error'] ?? 'Failed to reset password.';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildAppBar(), // <-- no padding here
              const SizedBox(height: 60),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }
}
