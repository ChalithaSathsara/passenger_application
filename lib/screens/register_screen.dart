import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
            borderRadius: BorderRadius.circular(30),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          colors: [
                            Color(0xFFBD2D01),
                            Color(0xFFCF4602),
                            Color(0xFFF67F00),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: const Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.white, // must be white for gradient to show
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: InkWell(
                        onTap: () {
                          // Add image picker logic here if needed
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Color(0xFFCF4602),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField("First Name", (val) => _firstName = val ?? ''),
            _buildTextField("Last Name", (val) => _lastName = val ?? ''),
            _buildTextField("Username", (val) => _username = val ?? ''),
            _buildTextField(
              "Email",
              (val) => _email = val ?? '',
              keyboardType: TextInputType.emailAddress,
            ),
            _buildPasswordField(
              label: "Password",
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              onSaved: (val) => _password = val ?? '',
            ),
            _buildPasswordField(
              label: "Confirm Password",
              isVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              onSaved: (val) => _confirmPassword = val ?? '',
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
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
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
              color: const Color(0xFFCF4602),
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBD2D01),
            Color(0xFFCF4602),
            Color(0xFFCF4602),
            Color(0xFFCF4602),
            Color(0xFFBD2D01),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, "/login");
          _formKey.currentState?.save();
        },
        child: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontSize: 16),
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
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.black,
              width: 2,
            ), // thicker border
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
              fontWeight: FontWeight.bold, // bold text
            ),
          ),
        ),
      ),
    );
  }
}
