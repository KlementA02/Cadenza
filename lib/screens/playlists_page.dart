import 'package:cadenza/screens/playlist_songs_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cadenza/controllers/player_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final controller = Get.find<PlayerController>();
  final isConnected = true.obs;
  final sortAlphabetical = false.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchDevicePlaylist();
  }

  void _sortPlaylists() {
    final list = controller.devicePlaylists;
    list.sort((a, b) =>
        sortAlphabetical.value ? a.playlist.compareTo(b.playlist) : 0);
    controller.devicePlaylists.assignAll([...list]);
  }

  @override
  Widget build(BuildContext context) {
    //final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlists"),
        actions: [
          Icon(
            isConnected.value ? Icons.wifi : Icons.wifi_off,
            color: isConnected.value ? Colors.green : Colors.red,
          ).animate().fade(duration: 500.ms).slideY(delay: 100.ms),
          IconButton(
            icon:
                Icon(sortAlphabetical.value ? Icons.sort_by_alpha : Icons.sort),
            onPressed: () {
              sortAlphabetical.toggle();
              _sortPlaylists();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context),
          ).animate(), // subtle pulse effect
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final playlists = controller.devicePlaylists;
        if (playlists.isEmpty) {
          return const Center(child: Text("No playlists found."));
        }

        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            final songCount =
                controller.playlistSongs[playlist.id]?.length ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.playlist_play),
                title: Text(playlist.playlist),
                subtitle: Text("$songCount songs"),
                onTap: () {
                  // Navigate to playlist songs
                  Get.to(
                    () => PlaylistSongsPage(
                        playlistId: playlist.id,
                        playlistName: playlist.playlist),
                  );
                },
              )
                  .animate() // Apply fade-in + slide
                  .fade(duration: 400.ms)
                  .slideX(
                      begin: 0.2, duration: 400.ms, delay: (100 * index).ms),
            );
          },
        );
      }),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Playlist"),
        content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: "Playlist name")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                controller.createDevicePlaylist(name);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
