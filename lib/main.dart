import 'package:flutter/material.dart';

import 'screens/login_screen.dart';


void main() {
  runApp(const AutoRickshawApp());
}

class AutoRickshawApp extends StatefulWidget {
  const AutoRickshawApp({super.key});

  @override
  State<AutoRickshawApp> createState() => _AutoRickshawAppState();
}

class _AutoRickshawAppState extends State<AutoRickshawApp> {
  bool isDarkMode = false;

  // Toggle dark/light theme
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apla Auto',
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode
              ? Colors.grey[900]
              : Colors.yellow.shade600,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      home: LoginScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}
