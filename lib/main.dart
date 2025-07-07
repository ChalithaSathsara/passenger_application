import 'package:flutter/material.dart';
import 'package:passenger_app/screens/login_screen.dart';
import 'package:passenger_app/screens/register_screen.dart';
import 'package:passenger_app/screens/forget_password_screen.dart';
import 'package:passenger_app/screens/forget_password_email_verification_screen.dart';
import 'package:passenger_app/screens/forget_password_enter_new_password_screen.dart';
import 'package:passenger_app/screens/Home_screen.dart';
import 'package:passenger_app/screens/sugest_screen.dart';
import 'package:passenger_app/screens/trip_planner_screen.dart';
import 'package:passenger_app/screens/places_around_location.dart';
import 'package:passenger_app/screens/live_map_scren.dart';
import 'package:passenger_app/screens/favourite_screen.dart';
import 'package:passenger_app/screens/notification_screen.dart';
import 'package:passenger_app/screens/more_screen.dart';
import 'package:passenger_app/screens/profile_screen.dart';
import 'package:passenger_app/screens/feedback_screen.dart';
import 'package:passenger_app/screens/help_and_support_screen.dart';
import 'package:passenger_app/screens/about_us_screen.dart';

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
      home: const Logingscreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/forget': (context) => const ForgotPasswordScreen(),

        '/home': (context) => const HomeScreen(),
        '/suggest': (context) => const SuggestScreen(),
        '/tripPlanner': (context) => const TripPlannerScreen(),
        '/placesAroundLocation': (context) =>
            const PlacesAroundLocationScreen(),
        '/liveMap': (context) => const LiveMapScreen(),
        '/favourites': (context) => const FavouriteScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/more': (context) => const MoreScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/helpAndSupport': (context) => const HelpAndSupport(),
        '/aboutUs': (context) => const AboutUsScreen(),
        '/login': (context) => const Logingscreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/RecoverPassword') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: args['email']),
          );
        }
        if (settings.name == '/EnterNewPassword') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: args['email']),
          );
        }
        return null;
      },
    );
  }
}
