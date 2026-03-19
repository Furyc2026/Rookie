import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/glossary/glossary_screen.dart';
import '../features/tips/tips_screen.dart';
import '../features/potential/potential_screen.dart';
import '../features/opener/opener_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void goToDashboard() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void goToGlossary() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void goToTips() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void goToPotential() {
    setState(() {
      _currentIndex = 3;
    });
  }

  void goToOpener() {
    setState(() {
      _currentIndex = 4;
    });
  }

  String get currentTitle {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Glossar';
      case 2:
        return 'Tipps';
      case 3:
        return 'Potential Check';
      case 4:
        return 'Opener Generator';
      default:
        return 'Energy Sales Rookie';
    }
  }

  Widget get currentScreen {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          onOpenGlossary: goToGlossary,
          onOpenTips: goToTips,
          onOpenPotential: goToPotential,
          onOpenOpener: goToOpener,
        );
      case 1:
        return const GlossaryScreen();
      case 2:
        return const TipsScreen();
      case 3:
        return const PotentialScreen();
      case 4:
        return const OpenerScreen();
      default:
        return DashboardScreen(
          onOpenGlossary: goToGlossary,
          onOpenTips: goToTips,
          onOpenPotential: goToPotential,
          onOpenOpener: goToOpener,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDashboard = _currentIndex == 0;

    return Scaffold(
      appBar: AppBar(
        leading: isDashboard
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: goToDashboard,
              ),
        title: Text(currentTitle),
        actions: [
          if (!isDashboard)
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: goToDashboard,
              tooltip: 'Zum Dashboard',
            ),
        ],
      ),
      body: currentScreen,
    );
  }
}