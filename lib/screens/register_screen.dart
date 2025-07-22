import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/profile_avatar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // Fields
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 360,
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
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png', // Your combined logo+text image
      width: 200,
      height: 130,
      fit: BoxFit.contain,
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 5, 5, 5).withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Add this line
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFBD2D01),
                  Color(0xFFCF4602),
                  Color(0xFFF67F00),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // must be white for gradient to show
                ),
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: const ProfileAvatar(
                profileImageUrl: null,
                radius: 30,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              "First Name",
              (val) => _firstName = val ?? '',
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'First name is required';
                return null;
              },
            ),
            _buildTextField(
              "Last Name",
              (val) => _lastName = val ?? '',
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'Last name is required';
                return null;
              },
            ),
            _buildTextField(
              "Email",
              (val) => _email = val ?? '',
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'Email is required';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(val.trim()))
                  return 'Enter a valid email';
                return null;
              },
            ),
            _buildPasswordField(
              label: "Password",
              controller: _passwordController,

              isVisible: _isPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onSaved: (val) => _password = val ?? '',
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password is required';
                if (val.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            _buildPasswordField(
              label: "Confirm Password",
              controller: _confirmPasswordController,
              isVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              onSaved: (val) => _confirmPassword = val ?? '',
              validator: (val) {
                print("Password controller: ${_passwordController.text}");
                print("Confirm controller: $val");
                if (val != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildRegisterButton(),
            const SizedBox(height: 10),
            _buildOrDivider(),
            const SizedBox(height: 10),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    void Function(String?) onSaved, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFFCF4602), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFFDE0CB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        onSaved: onSaved,
        validator: validator, // <-- add this
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required TextEditingController controller,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFFCF4602), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFFDE0CB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Color.fromARGB(255, 194, 44, 14),
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
        onSaved: onSaved,
        validator: validator, // <-- add this
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () async {
          print('[DEBUG] Register button pressed');
          if (_formKey.currentState?.validate() ?? false) {
            print('[DEBUG] Form validated');
            _formKey.currentState?.save();

            // Call registration API
            print(
              '[DEBUG] Sending registration data: FirstName=\${_firstName}, LastName=\${_lastName}, Email=\${_email}, Password=\${_password}',
            );
            bool success = await _registerPassenger(
              firstName: _firstName,
              lastName: _lastName,
              email: _email,
              password: _password,
            );

            print('[DEBUG] Registration API success: \\${success}');
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration successful!')),
              );
              Navigator.pushNamed(context, "/login");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration failed!')),
              );
            }
          } else {
            print('[DEBUG] Form validation failed');
          }
        },
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ShaderMask(
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
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: const Text(
              "OR",
              style: TextStyle(
                color: Colors.white, // Color here is ignored but must be set
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
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
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _handleGoogleSignIn,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: Image.asset('assets/images/google.png', width: 20, height: 20),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _registerPassenger({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger',
    );
    final body = jsonEncode({
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "Password": password,
    });
    print('[DEBUG] Registration JSON body: $body');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print('[DEBUG] Registration response status: ${response.statusCode}');
    print('[DEBUG] Registration response body: ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Always sign out first to force account picker
      await _googleSignIn.signOut();

      print('[DEBUG] Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('[DEBUG] Google Sign-In cancelled by user');
        return;
      }

      print('[DEBUG] Google Sign-In successful: ${googleUser.email}');
      
      // Get user details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        print('[DEBUG] Failed to get Google tokens');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to authenticate with Google')),
        );
        return;
      }

      // Register user with backend using Google credentials
      bool success = await _registerWithGoogle(
        email: googleUser.email,
        firstName: googleUser.displayName?.split(' ').first ?? '',
        lastName: googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        profilePictureUrl: googleUser.photoUrl ?? '',
        googleAccessToken: accessToken,
        googleIdToken: idToken,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google registration successful!')),
        );
        Navigator.pushNamed(context, "/login");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google registration failed!')),
        );
      }
    } catch (error) {
      print('[DEBUG] Google Sign-In error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In error: $error')),
      );
    }
  }

  Future<bool> _registerWithGoogle({
    required String email,
    required String firstName,
    required String lastName,
    required String profilePictureUrl,
    required String googleAccessToken,
    required String googleIdToken,
  }) async {
    try {
      final url = Uri.parse(
        'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/register-google',
      );
      
      final body = jsonEncode({
        "idToken": googleIdToken,
        "passenger": {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "avatarId": 1, // Default avatar ID, you can modify this as needed
        }
      });

      print('[DEBUG] Google registration JSON body: $body');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('[DEBUG] Google registration response status: ${response.statusCode}');
      print('[DEBUG] Google registration response body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[DEBUG] Google registration error: $e');
      return false;
    }
  }
}
