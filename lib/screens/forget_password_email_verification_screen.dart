import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity, // make sure it fills the width
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max, // force the row to fill horizontally
        children: const [
          BackButton(color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Email Verification",
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
        "Get Your Code",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubtitleText() {
    return const Text(
      "Please enter the 4-digit code that sent to your email address.",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 120, 118, 118)),
    );
  }

  Widget _buildOtpField() {
    return Container(
      width: 250, // 4 x 50 + spacing approximation
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 246, 182, 139), // low orange border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.text,
        maxLength: 4,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        ],
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "If you don’t receive the code! ",
          style: TextStyle(
            fontSize: 13,
            color: Color.fromARGB(255, 120, 118, 118),
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Add resend logic
          },
          child: const Text(
            "Resend",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
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
            // Handle verification logic here
            Navigator.pushNamed(context, '/EnterNewPassword');
          },
          child: const Text(
            "Verify and Proceed",
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
          _buildHeaderText(),
          const SizedBox(height: 8),
          _buildSubtitleText(),
          const SizedBox(height: 16),
          _buildOtpField(),
          const SizedBox(height: 4), // reduced from 16
          _buildResendSection(),
          const SizedBox(height: 4), // reduced from 12
          _buildVerifyButton(),
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
              _buildAppBar(), // << NO padding here
              const SizedBox(height: 60),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }
}
