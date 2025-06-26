import 'package:flutter/material.dart';
import 'package:passenger_app/screens/login_screen.dart';
import 'package:passenger_app/screens/register_screen.dart';
import 'package:passenger_app/screens/forget_password_screen.dart';
import 'package:passenger_app/screens/forget_password_email_verification_screen.dart';
import 'package:passenger_app/screens/forget_password_enter_new_password_screen.dart';
import 'package:passenger_app/screens/Home_screen.dart';
import 'package:passenger_app/screens/sugest_screen.dart';
import 'package:passenger_app/screens/trip_planner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
      ),
      home: const TripPlannerScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/forget': (context) => const ForgotPasswordScreen(),
        '/RecoverPassword': (context) => const EmailVerificationScreen(),
        '/EnterNewPassword': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/suggest': (context) => const SuggestScreen(),
      },
    );
  }
}
