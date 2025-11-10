import 'package:flutter/material.dart';
import 'package:localsend_app/pages/home_page.dart';
import 'package:localsend_app/pages/splash_screen.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    } else {
      return const HomePage(
        initialTab: HomeTab.receive,
        appStart: true,
      );
    }
  }
}
