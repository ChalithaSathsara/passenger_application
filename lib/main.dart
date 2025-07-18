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

        '/placesAroundLocation': (context) =>
            const PlacesAroundLocationScreen(),
        '/profile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final passengerId = args?['passengerId'] as String? ?? '';
          return ProfileScreen(passengerId: passengerId);
        },
        '/feedback': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final passengerId = args?['passengerId'] as String? ?? '';
          return FeedbackScreen(passengerId: passengerId);
        },
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
        if (settings.name == '/home') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(passengerId: args['passengerId']),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for home screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/more') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  MoreScreen(passengerId: args['passengerId']),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for more screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/tripPlanner') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  TripPlannerScreen(passengerId: args['passengerId']),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for trip planner screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/liveMap') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  LiveMapScreen(passengerId: args['passengerId']),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for live map screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/favourites') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            final showBuses =
                args['showBuses'] ?? true; // Default to true if not provided
            return MaterialPageRoute(
              builder: (context) => FavouriteScreen(
                key: ValueKey(
                  'favourites_${showBuses}_${DateTime.now().millisecondsSinceEpoch}',
                ),
                passengerId: args['passengerId'],
                initialShowBuses: showBuses,
              ),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for favourites screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/notifications') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            return MaterialPageRoute(
              builder: (context) =>
                  NotificationsScreen(passengerId: args['passengerId']),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for notifications screen'),
                ),
              ),
            );
          }
        }
        if (settings.name == '/suggest') {
          final args = settings.arguments;
          if (args is Map<String, dynamic> && args['passengerId'] != null) {
            final showBuses =
                args['showBuses'] ?? true; // Default to true if not provided
            return MaterialPageRoute(
              builder: (context) => SuggestScreen(
                key: ValueKey(
                  'suggest_${showBuses}_${DateTime.now().millisecondsSinceEpoch}',
                ),
                passengerId: args['passengerId'],
                initialShowBuses: showBuses,
              ),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Missing passengerId for suggest screen'),
                ),
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
