import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'widgets/app_shell.dart';

class EnergySalesRookieApp extends StatelessWidget {
  const EnergySalesRookieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Sales Rookie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}