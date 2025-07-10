import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String passengerId;

  const ProfileScreen({super.key, required this.passengerId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder for profile image URL from DB
  String? profileImageUrl;
  bool _isLoadingImage = true;
  bool _hasImageError = false;

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileImageAndDetails();
  }

  Future<void> _fetchProfileImageAndDetails() async {
    try {
      setState(() {
        _isLoadingImage = true;
        _hasImageError = false;
      });

      // Get the passenger data to extract the profile image URL and details
      final passengerUrl =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/${widget.passengerId}';
      print('Fetching passenger data from: $passengerUrl');

      final passengerResponse = await http.get(Uri.parse(passengerUrl));

      print('Passenger response status: ${passengerResponse.statusCode}');
      print('Passenger response body: ${passengerResponse.body}');

      if (passengerResponse.statusCode == 200) {
        try {
          final Map<String, dynamic> passengerData = jsonDecode(
            passengerResponse.body,
          );
          print('Parsed passenger data: $passengerData');

          final imageUrl = passengerData['profileImageUrl'];
          print('Extracted profile image URL: $imageUrl');

          // Set text field values
          _firstNameController.text = passengerData['firstName'] ?? '';
          _lastNameController.text = passengerData['lastName'] ?? '';
          _emailController.text = passengerData['email'] ?? '';

          if (imageUrl != null && imageUrl.isNotEmpty) {
            await _testImageUrl(imageUrl);
          } else {
            print('No profile image URL found in passenger data');
            setState(() {
              _isLoadingImage = false;
              _hasImageError = false; // Not really an error, just no image
            });
          }
        } catch (jsonError) {
          print('JSON parsing error for passenger data: $jsonError');
          setState(() {
            _isLoadingImage = false;
            _hasImageError = true;
          });
        }
      } else {
        print(
          'Failed to fetch passenger data: ${passengerResponse.statusCode}',
        );
        setState(() {
          _isLoadingImage = false;
          _hasImageError = true;
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
      setState(() {
        _isLoadingImage = false;
        _hasImageError = true;
      });
    }
  }

  Future<void> _testImageUrl(String imageUrl) async {
    try {
      print('Testing image URL accessibility: $imageUrl');

      final response = await http.head(Uri.parse(imageUrl));
      print('Image URL test status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Image URL is accessible');
        setState(() {
          profileImageUrl = imageUrl;
          _isLoadingImage = false;
        });
        print('Profile image URL set successfully: $imageUrl');
      } else {
        print('Image URL is not accessible (status: ${response.statusCode})');
        // Try to convert Google Drive URL to direct download link
        if (imageUrl.contains('drive.google.com')) {
          final directUrl = _convertGoogleDriveUrl(imageUrl);
          print('Trying converted Google Drive URL: $directUrl');

          final directResponse = await http.head(Uri.parse(directUrl));
          if (directResponse.statusCode == 200) {
            print('Converted Google Drive URL is accessible');
            setState(() {
              profileImageUrl = directUrl;
              _isLoadingImage = false;
            });
            print('Profile image URL set successfully: $directUrl');
          } else {
            print('Converted Google Drive URL is not accessible');
            setState(() {
              _isLoadingImage = false;
              _hasImageError = true;
            });
          }
        } else {
          setState(() {
            _isLoadingImage = false;
            _hasImageError = true;
          });
        }
      }
    } catch (e) {
      print('Error testing image URL: $e');
      setState(() {
        _isLoadingImage = false;
        _hasImageError = true;
      });
    }
  }

  String _convertGoogleDriveUrl(String originalUrl) {
    // Convert Google Drive sharing URL to direct download URL
    if (originalUrl.contains('drive.google.com/uc?id=')) {
      final fileId = originalUrl.split('id=')[1];
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return originalUrl;
  }

  // Debug method to test if passenger exists
  Future<void> _testPassengerExists() async {
    try {
      final url =
          'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/passenger/${widget.passengerId}';
      print('Testing passenger existence at: $url');

      final response = await http.get(Uri.parse(url));
      print('Passenger test response status: ${response.statusCode}');
      print('Passenger test response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Passenger exists in database');
      } else if (response.statusCode == 404) {
        print('Passenger not found in database');
      } else {
        print('Unexpected response for passenger test');
      }
    } catch (e) {
      print('Error testing passenger existence: $e');
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildForm(),
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
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1, // Adjust thickness if you want
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(
              context,
              '/more',
              arguments: {'passengerId': widget.passengerId},
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Profile",
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

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // darker shadow
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFFFFA54F),
                backgroundImage:
                    profileImageUrl != null &&
                        !_isLoadingImage &&
                        !_hasImageError
                    ? NetworkImage(profileImageUrl!)
                    : null,
                onBackgroundImageError:
                    profileImageUrl != null &&
                        !_isLoadingImage &&
                        !_hasImageError
                    ? (exception, stackTrace) {
                        print('Error loading profile image: $exception');
                        setState(() {
                          _hasImageError = true;
                        });
                      }
                    : null,
                child: _isLoadingImage
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : profileImageUrl == null || _hasImageError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'No Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Handle edit profile picture
                    print("Edit profile picture tapped");
                    // For now, refresh the profile image
                    _fetchProfileImageAndDetails();
                    // TODO: Add image picker functionality here
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFFBD2D01),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _firstNameController, hint: "John"),
          const SizedBox(height: 12),
          _buildTextField(controller: _lastNameController, hint: "Rubic"),

          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            hint: "john99@gmail.com",
          ),
          const SizedBox(height: 12),
          _buildPasswordField(
            hint: "********",
            obscure: _obscurePassword,
            onToggle: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildPasswordField(
            hint: "********",
            obscure: _obscureConfirm,
            onToggle: () {
              setState(() {
                _obscureConfirm = !_obscureConfirm;
              });
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              shadowColor: Colors.black.withOpacity(0.7),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // Handle update
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF0E0),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFF0E0),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFFBD2D01),
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
      ),
    );
  }
}
