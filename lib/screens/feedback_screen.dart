import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackScreen extends StatefulWidget {
  final String passengerId;
  const FeedbackScreen({super.key, required this.passengerId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _subjectError;
  String? _messageError;
  List<Map<String, dynamic>> _pastFeedbacks = [];
  bool _isLoadingFeedbacks = false;
  bool _showPastFeedbacks = false;

  @override
  void initState() {
    super.initState();
    _fetchPastFeedbacks();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _subjectError = _subjectController.text.trim().isEmpty
          ? 'Subject is required'
          : null;
      _messageError = _messageController.text.trim().isEmpty
          ? 'Message is required'
          : null;
    });
    if (_subjectError != null || _messageError != null) return;

    final url = Uri.parse(
      'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Feedback',
    );
    print({
      'passengerId': widget.passengerId,
      'subject': _subjectController.text.trim(),
      'message': _messageController.text.trim(),
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'passengerId': widget.passengerId,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _subjectError = null;
        _messageError = null;
      });
      _fetchPastFeedbacks(); // Refresh past feedbacks after submission
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: \\${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> _fetchPastFeedbacks() async {
    setState(() {
      _isLoadingFeedbacks = true;
    });
    try {
      final url = Uri.parse('https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/api/Feedback');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> feedbacks = jsonDecode(response.body);
        setState(() {
          _pastFeedbacks = feedbacks
              .where((fb) => fb['passengerId'] == widget.passengerId)
              .cast<Map<String, dynamic>>()
              .toList();
          _isLoadingFeedbacks = false;
        });
      } else {
        setState(() {
          _isLoadingFeedbacks = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingFeedbacks = false;
      });
    }
  }

  Widget _buildPastFeedbacksSection() {
    if (!_showPastFeedbacks) {
      return const SizedBox.shrink();
    }
    if (_isLoadingFeedbacks) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pastFeedbacks.isEmpty) {
      return const Center(child: Text('No past feedbacks found.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Past Feedbacks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pastFeedbacks.length,
          itemBuilder: (context, idx) {
            final fb = _pastFeedbacks[idx];
            final status = (fb['reply'] != null && (fb['reply'] as String).isNotEmpty)
                ? 'Feedback Closed'
                : 'Feedback Raised';
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${fb['subject'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Message: ${fb['message'] ?? ''}'),
                    if (fb['reply'] != null && (fb['reply'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Reply: ${fb['reply']}'),
                    ],
                    const SizedBox(height: 4),
                    Text('Created: ${fb['createdTime']?.toString().split("T").first ?? ''}'),
                    if (fb['repliedTime'] != null && (fb['repliedTime'] as String).isNotEmpty)
                      Text('Replied: ${fb['repliedTime'].toString().split("T").first}'),
                    const SizedBox(height: 4),
                    Text('Status: $status', style: TextStyle(fontWeight: FontWeight.bold, color: status == 'Feedback Closed' ? Colors.green : Colors.orange)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildForm(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPastFeedbacks = !_showPastFeedbacks;
                            });
                          },
                          child: Text(_showPastFeedbacks ? 'Hide Past Feedbacks' : 'Show Past Feedbacks'),
                        ),
                      ),
                    ),
                    _buildPastFeedbacksSection(),
                  ],
                ),
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
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Feedback",
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ).createShader(bounds);
            },
            child: const Text(
              "Feedback",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Color gets replaced by shader
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(hint: "Subject", controller: _subjectController),
          if (_subjectError != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 6),
              child: Text(
                _subjectError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          _buildTextField(
            hint: "Message",
            maxLines: 5,
            controller: _messageController,
          ),
          if (_messageError != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 6),
              child: Text(
                _messageError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
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
                onTap: _submitFeedback,
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
                    "Submit",
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
    required String hint,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFFFF0E0),
        hintText: hint,
        hintStyle: TextStyle(
          color: Color.fromARGB(255, 240, 120, 83), // orange hint text color
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