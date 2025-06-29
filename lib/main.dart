import 'package:flutter/material.dart';
import 'screens/watch_face_screen.dart';
import 'widgets/splash_screen.dart';

void main() {
  runApp(SmartwatchCalorieApp());
}

class SmartwatchCalorieApp extends StatelessWidget {
  const SmartwatchCalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartwatch Calories',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.green,
          surface: Colors.grey[900]!,
        ),
      ),
      home: SplashScreen(
        child: WatchFaceScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}