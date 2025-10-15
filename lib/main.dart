import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/screens/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize audio service first
    await PlayerController.initAudioService();

    runApp(const MainApp());
  } catch (e) {
    debugPrint('Fatal error during initialization: $e');
    // Handle fatal initialization errors
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: KAppThemes.lightTheme,
      darkTheme: KAppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const NavigationScreen(),
    );
  }
}
