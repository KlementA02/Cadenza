import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/screens/album_songs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var controller = Get.put(PlayerController());
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.person,
                          color: theme.colorScheme.onPrimary),
                    ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.settings))
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome back, Klement',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Redesigned Now Playing Section
                Obx(() {
                  final song = controller.currentSongRx.value;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.surface,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song?.id ?? 0,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 80,
                            artworkWidth: 80,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              width: 80,
                              height: 80,
                              color: theme.colorScheme.surface,
                              child: Icon(Icons.music_note,
                                  size: 40, color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song?.title ?? 'No song playing',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song?.artist ?? '',
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.isPlaying.value
                                ? Iconsax.pause
                                : Iconsax.play,
                            size: 24,
                          ),
                          onPressed: controller.togglePlayPause,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                const Text(
                  'Your Albums',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.currentAlbum.isEmpty) {
                    return const Center(child: Text('No albums found'));
                  } else {
                    return SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.currentAlbum.length,
                        itemBuilder: (context, index) {
                          final album = controller.currentAlbum[index];
                          return TrackWidget(
                            albumTitle: album.album,
                            albums: controller.currentAlbum,
                            queryArtwork: QueryArtworkWidget(
                              artworkHeight: 180,
                              artworkWidth: 160,
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              artworkBorder: BorderRadius.circular(2),
                              artworkFit: BoxFit.cover,
                              nullArtworkWidget: const Center(
                                child: Icon(
                                  Icons.album,
                                  size: 150,
                                ),
                              ),
                            ),
                            albumId: album.id,
                          );
                        },
                      ),
                    );
                  }
                }),
                const SizedBox(height: 24),
                const Text(
                  'Recommended For You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final recommendations = controller.recommendations;

                  if (recommendations.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return MasonryGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: recommendations.entries.length,
                    itemBuilder: (context, index) {
                      final category = recommendations.keys.elementAt(index);
                      final songs = recommendations[category]!;

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                category,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: songs.length.clamp(0, 5),
                                itemBuilder: (context, songIndex) {
                                  final song = songs[songIndex];
                                  return GestureDetector(
                                    onTap: () => controller.playSong(song),
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: QueryArtworkWidget(
                                              id: song.id,
                                              type: ArtworkType.AUDIO,
                                              artworkHeight: 120,
                                              artworkWidth: 120,
                                              artworkFit: BoxFit.cover,
                                              nullArtworkWidget: Container(
                                                height: 120,
                                                width: 120,
                                                color:
                                                    theme.colorScheme.surface,
                                                child: Icon(
                                                  Icons.music_note,
                                                  size: 40,
                                                  color: theme
                                                      .colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            song.displayNameWOExt,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 20),
                // Additional Suggestions for Offline Music App
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickTile(Icons.favorite, 'Favorites', () {}),
                    //_quickTile(Icons.download, 'Downloads', () {}),
                    _quickTile(Icons.history, 'Recently Played', () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(Get.context!).colorScheme.primary,
            radius: 22,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12))
        ],
      ),
    );
  }
}

class TrackWidget extends StatelessWidget {
  const TrackWidget({
    super.key,
    required this.albumTitle,
    required this.albums,
    required this.queryArtwork,
    required this.albumId,
  });
  final String albumTitle;
  final List<AlbumModel> albums;
  final Widget queryArtwork;
  final int albumId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var controller = Get.put(PlayerController());
    return GestureDetector(
      onTap: () {
        controller.fetchSongFromAlbum(albumId);
        Get.to(() => AlbumSongScreen(albumId: albumId, albumTitle: albumTitle));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: queryArtwork,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  albumTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
