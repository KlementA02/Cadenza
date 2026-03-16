import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/screens/allsongs_screen.dart';
import 'package:cadenza/screens/home_screen.dart';
import 'package:cadenza/screens/playlists_page.dart';
import 'package:cadenza/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool isMiniPlayerVisible = false; // Track visibility of the mini player

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayerController());
    final navigationController = Get.put(NavigationScreenController());

    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() => IndexedStack(
                  index: navigationController.selectedIndex.value,
                  children: navigationController.screens,
                )),
            MiniPlayerWidget(
                isMiniPlayerVisible: isMiniPlayerVisible,
                controller: controller),
          ],
        ),
        bottomNavigationBar: Obx(
          () => NavigationBar(
            backgroundColor: theme.colorScheme.surface,
            height: 60,
            elevation: 0,
            selectedIndex: navigationController.selectedIndex.value,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
            onDestinationSelected: (value) =>
                navigationController.selectedIndex.value = value,
            destinations: const [
              NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Iconsax.music_playlist), label: 'All Songs'),
              NavigationDestination(
                  icon: Icon(Iconsax.search_normal), label: 'Search'),
              NavigationDestination(
                  icon: Icon(Icons.library_music_outlined), label: 'Playlists'),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isMiniPlayerVisible = !isMiniPlayerVisible; // Toggle visibility
              });
            },
            child: const Icon(Iconsax.smileys),
          ),
        ),
      ),
    );
  }
}

class NavigationScreenController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final List<Widget> screens = [
    const HomeScreen(),
    const AllSongsScreen(),
    const SearchScreen(),
    const PlaylistsPage(),
  ];
}
