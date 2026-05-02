import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const ReliefNetApp());
}

class ReliefNetApp extends StatelessWidget {
  const ReliefNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReliefNet AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
