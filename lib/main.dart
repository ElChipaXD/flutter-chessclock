import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 123, 123, 123),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 123, 123, 123),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
    );
  }
}
