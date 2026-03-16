import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/controllers/theme_controller.dart';
import 'package:cadenza/screens/navigation_screen.dart';
import 'package:cadenza/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    Get.put(ThemeController());

    return Obx(() {
      final themeController = Get.find<ThemeController>();

      return GetMaterialApp(
        theme: KAppThemes.buildLightTheme(themeController.accent),
        darkTheme: KAppThemes.buildDarkTheme(themeController.accent),
        themeMode: themeController.themeMode,
        home: const NavigationScreen(),
      );
    });
  }
}
