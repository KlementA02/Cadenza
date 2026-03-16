import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:cadenza/controllers/player_controller.dart';

class AlbumSongScreen extends StatelessWidget {
  final int albumId;
  final String albumTitle;

  const AlbumSongScreen({
    super.key,
    required this.albumId,
    required this.albumTitle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetch songs when screen is built
    controller.fetchSongFromAlbum(albumId);

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QueryArtworkWidget(
                      id: albumId,
                      type: ArtworkType.ALBUM,
                      artworkHeight: 100,
                      artworkWidth: 100,
                      artworkBorder: BorderRadius.circular(12),
                      nullArtworkWidget: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.colorScheme.surface,
                        ),
                        child: Icon(Icons.album,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            albumTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _modernButton(
                                label: 'Play All',
                                icon: Icons.play_arrow_rounded,
                                onPressed: () {
                                  controller.playPlaylist(
                                      controller.currentPlaylist, 0);
                                },
                                isDark: isDark,
                              ),
                              const SizedBox(width: 10),
                              _modernButton(
                                label: 'Shuffle',
                                icon: Icons.shuffle,
                                onPressed: () {
                                  controller.toggleShuffle();
                                  controller.playPlaylist(
                                      controller.currentPlaylist, 0);
                                },
                                isDark: isDark,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5),

              // Song List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.currentPlaylist.isEmpty) {
                    return const Center(
                      child: Text("No songs found in this album."),
                    );
                  }

                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: controller.currentPlaylist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final song = controller.currentPlaylist[index];
                      return Material(
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              artworkHeight: 50,
                              artworkWidth: 50,
                              artworkFit: BoxFit.cover,
                              nullArtworkWidget: Container(
                                height: 50,
                                width: 50,
                                color: theme.colorScheme.surface,
                                child: Icon(Icons.music_note,
                                    color: theme.colorScheme.onSurface),
                              ),
                            ),
                          ),
                          title: Text(
                            song.displayNameWOExt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            song.artist ?? "Unknown Artist",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: const Icon(Icons.more_vert),
                          onTap: () => controller.playSong(song),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
