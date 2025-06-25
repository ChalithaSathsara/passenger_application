import 'package:flutter/material.dart';

class Logingscreen extends StatefulWidget {
  const Logingscreen({super.key});

  @override
  State<Logingscreen> createState() => _LogingscreenState();
}

class _LogingscreenState extends State<Logingscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png', // your logo image file path
      height: 180, // set your desired height
      fit: BoxFit.contain, // optional: keep aspect ratio
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      style: const TextStyle(fontSize: 16), // input text size
      decoration: InputDecoration(
        hintText: 'Email or username',
        hintStyle: const TextStyle(
          color: Color(0xFFFF6600),
          fontSize: 14, // standard hint size
        ),
        prefixIcon: const Icon(Icons.person_outline, size: 20),
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
      style: const TextStyle(fontSize: 16),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(color: Color(0xFFFF6600), fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            size: 20,
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
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
            Color(0xFFBD2D01),
            Color(0xFFCF4602),
            Color(0xFFCF4602),
            Color(0xFFCF4602),
            Color(0xFFBD2D01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              print('Email: $_email');
              print('Password: $_password');
            }
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
                  const SizedBox(height: 20), // bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
