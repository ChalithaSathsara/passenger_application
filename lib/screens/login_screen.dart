import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../signalr_connection.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool _isLoadingLogin = false;
  bool _isLoadingGoogle = false;

  String? _emailError;
  String? _passwordError;

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
      autofocus: true,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Email or username',
        hintStyle: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 14,
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
        errorText: _emailError,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+ *$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
        return null;
      },
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
      textInputAction: TextInputAction.done,
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
            color: const Color.fromARGB(255, 194, 44, 14),
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
        errorText: _passwordError,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onSaved: (value) {
        _password = value!;
      },
      onFieldSubmitted: (_) {
        if (!_isLoadingLogin && !_isLoadingGoogle) {
          _submitLoginForm();
        }
      },
    );
  }

  void _submitLoginForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      _login();
    }
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
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: _isLoadingLogin || _isLoadingGoogle
              ? null
              : _submitLoginForm,
          child: _isLoadingLogin
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
              color: Colors.black,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: _isLoadingGoogle
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
              : Image.asset('assets/images/google.png', height: 20),
          label: Text(
            _isLoadingGoogle ? 'Signing in...' : 'Continue with Google',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isLoadingLogin || _isLoadingGoogle
              ? null
              : _handleGoogleSignIn,
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
    setState(() {
      _isLoadingLogin = true;
    });
    try {
      // First, check if the email is registered
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
          final Map<String, dynamic> loginData = jsonDecode(loginResponse.body);
          final String firstName = loginData['firstName'] ?? '';
          final String lastName = loginData['lastName'] ?? '';
          final String fullName = (firstName + ' ' + lastName).trim();
          NotificationSignalRService.instance.connect(passengerId: _passengerId);
          NotificationSignalRService.instance.setPassengerId(_passengerId);
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'passengerId': _passengerId,
              'initialFullName': fullName,
            },
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
    } finally {
      setState(() {
        _isLoadingLogin = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoadingGoogle = true;
    });
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        print('[DEBUG] Failed to get Google ID token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to authenticate with Google')),
        );
        return;
      }
      // Call backend to login with Google
      bool success = await _loginWithGoogle(
        email: googleUser.email,
        googleIdToken: idToken,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google login successful!')),
        );
        // Get passengerId from backend
        final passengerId = await _getPassengerIdByEmail(googleUser.email);
        if (passengerId != null) {
          NotificationSignalRService.instance.connect(passengerId: passengerId);
          NotificationSignalRService.instance.setPassengerId(passengerId);
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {'passengerId': passengerId},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not retrieve passenger ID.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google login failed!')),
        );
      }
    } catch (error) {
      print('[DEBUG] Google Sign-In error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In error: $error')),
      );
    } finally {
      setState(() {
        _isLoadingGoogle = false;
      });
    }
  }

  Future<bool> _loginWithGoogle({
    required String email,
    required String googleIdToken,
  }) async {
    try {
      final url = Uri.parse(
        'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/google-signin',
      );
      final body = jsonEncode({
        "idToken": googleIdToken,
      });
      print('[DEBUG] Google login JSON body: $body');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('[DEBUG] Google login response status: ${response.statusCode}');
      print('[DEBUG] Google login response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('[DEBUG] Google login error: $e');
      return false;
    }
  }

  Future<String?> _getPassengerIdByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Passenger/get-id-by-email/${Uri.encodeComponent(email)}',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['passengerId'] as String?;
      }
    } catch (e) {
      print('[DEBUG] Error getting passengerId by email: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(),
                          const SizedBox(height: 15),
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
                                        color: Colors.white,
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
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
