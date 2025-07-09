import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Logingscreen extends StatefulWidget {
  const Logingscreen({super.key});

  @override
  State<Logingscreen> createState() => _LogingscreenState();
}

class _LogingscreenState extends State<Logingscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _passengerId = ''; // Add passenger ID variable
  bool _isPasswordVisible = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png', // your logo image file path
      height: 180, // set your desired height
      fit: BoxFit.contain, // optional: keep aspect ratio
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      focusNode: _emailFocus,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16), // input text size
      decoration: InputDecoration(
        hintText: 'Email or username',
        hintStyle: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 14, // standard hint size
        ),
        prefixIcon: const Icon(
          Icons.person_outline,
          size: 20,
          color: Color.fromARGB(255, 194, 44, 14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFFFE5D0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onSaved: (value) {
        _email = value!;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      focusNode: _passwordFocus,
      style: const TextStyle(fontSize: 16),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(color: Color(0xFFFF6600), fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Color.fromARGB(255, 194, 44, 14),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: const Color.fromARGB(255, 194, 44, 14), // icon color
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFFFE5D0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onSaved: (value) {
        _password = value!;
      },
    );
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/forget');
        },
        child: const Text(
          'Forget Password?',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
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
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 5, 5, 5).withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.transparent, // make button background transparent
            shadowColor: Colors
                .transparent, // remove button shadow, using container shadow
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: () {
            _formKey.currentState?.save(); // Save the form data
            _login(); // Call the login method
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold, // white text on gradient background
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.red)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("OR", style: TextStyle(color: Colors.red, fontSize: 13)),
        ),
        Expanded(child: Divider(color: Colors.red)),
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
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.black, // changed from transparent to black
              width: 2, // thicker border width
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Image.asset('assets/images/google.png', height: 20),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold, // make text bold
            ),
          ),
          onPressed: () {
            print("Google login clicked");
          },
        ),
      ),
    );
  }

  Widget _buildRegisterText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No account?', style: TextStyle(fontSize: 13)),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/register',
            ); // 👈 Navigate to RegisterPage
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    // First, check if the email is registered
    try {
      final emailCheckResponse = await http.get(
        Uri.parse(
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/get-id-by-email/${Uri.encodeComponent(_email)}',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (emailCheckResponse.statusCode == 200) {
        // Email is registered, get the passenger ID
        final Map<String, dynamic> emailData = jsonDecode(
          emailCheckResponse.body,
        );
        _passengerId = emailData['passengerId'];
        print('Passenger ID: $_passengerId');

        // Now proceed with login
        final loginResponse = await http.post(
          Uri.parse(
            'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/login',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'Email': _email,
            'Password': _password,
          }),
        );

        if (loginResponse.statusCode == 200) {
          // Login successful, navigate to home with passenger ID
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'passengerId': _passengerId},
          );
        } else {
          String errorMsg = 'Login failed. Please try again.';
          try {
            final Map<String, dynamic> body = jsonDecode(loginResponse.body);
            print('API Error: ${body['error']}');
            print('API Message: ${body['message']}');
            print('API Response: ${loginResponse.body}');
            print('API URL: ${loginResponse.request?.url}');

            if (body['error'] == 'INVALID_LOGIN_CREDENTIALS') {
              errorMsg = 'Invalid username or password.';
            } else if (body['error'] == 'INVALID_EMAIL') {
              errorMsg = 'Invalid email format.';
            } else if (body['error'] == 'MISSING_PASSWORD') {
              errorMsg = 'Please enter your password.';
            } else if (body['message'] != null) {
              errorMsg = body['message'];
            }
          } catch (e) {
            print('Error parsing response: $e');
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Failed'),
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
      } else {
        // Email is not registered
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Not Registered'),
            content: const Text(
              'This email address is not registered. Please register first or use a different email.',
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
      print('Error checking email: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text(
            'Unable to connect to the server. Please check your internet connection and try again.',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use a Container to apply vertical gradient background
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
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // top spacing
                  _buildLogo(),
                  const SizedBox(height: 15), // spacing after logo

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            5,
                            5,
                            5,
                          ).withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Gradient Login Text with vertical gradient
                          ShaderMask(
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
                                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // required for ShaderMask
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 12),
                          _buildPasswordField(),
                          _buildForgotPassword(),
                          const SizedBox(height: 8),
                          _buildLoginButton(),
                          const SizedBox(height: 12),
                          _buildOrDivider(),
                          const SizedBox(height: 8),
                          _buildGoogleButton(),
                          const SizedBox(height: 8),
                          _buildRegisterText(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
