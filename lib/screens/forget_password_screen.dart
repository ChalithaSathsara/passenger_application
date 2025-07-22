import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forget_password_email_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black, // Black line
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: const [
          BackButton(color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Forgot Password",
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

  Widget _buildHeaderText() {
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
        "Mail Address Here",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubtitleText() {
    return const Text(
      "Enter the email address associated\nwith your account",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 120, 118, 118)),
    );
  }

  Widget _buildEmailInputField() {
    return TextField(
      controller: _emailController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: "Enter the email address",
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFFF6600)),
        filled: true,
        fillColor: const Color(0xFFFFE5D0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    // Simple email pattern, you can use a stricter one if needed
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Widget _buildRecoverButton() {
    return Container(
      width: double
          .infinity, // Let it naturally fill the form card’s internal padding
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
          minimumSize: const Size.fromHeight(50), // Match height visually
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero, // Button padding handled by container
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _recoverPassword();
        },
        child: const Text(
          "Recover Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _recoverPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    final url =
        'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );

      print('API URL: $url');
      print('API Request Body: ${jsonEncode({'Email': email})}');
      print('API Status Code: ${response.statusCode}');
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text(
              'Password recovery instructions sent to your email.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/RecoverPassword',
                    arguments: {'email': email},
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final body = jsonDecode(response.body);
        print('API Error: ${body['error']}');
        print('API Message: ${body['message']}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              body['message'] ??
                  body['error'] ??
                  'Failed to send recovery email.',
            ),
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
      print('Exception: $e');
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
          _buildHeaderText(),
          const SizedBox(height: 8),
          _buildSubtitleText(),
          const SizedBox(height: 12),
          _buildEmailInputField(),
          const SizedBox(height: 16),
          _buildRecoverButton(),
        ],
      ),
    );
  }

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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildAppBar(), // Removed extra Padding
              const SizedBox(height: 60),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }
}
