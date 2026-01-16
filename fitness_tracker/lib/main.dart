import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/// Main entry point for the Fitness Tracker app
/// 
/// This app is a simple, offline-first fitness tracking application
/// for logging gym workouts, tracking exercises, and viewing progress.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FitnessTrackerApp());
}
