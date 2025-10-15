import 'dart:ui';

import 'package:cadenza/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class NowPlayingScreen extends StatelessWidget {
  final controller = Get.find<PlayerController>();

  NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController playlistController = TextEditingController();

    return Obx(() {
      final currentSong = controller.currentSongRx.value;
      if (currentSong == null || controller.currentPlaylist.isEmpty) {
        return const Center(
          child: Text("Select a song to play",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        );
      } else {
        return Stack(
          children: [
            // Background
            QueryArtworkWidget(
              id: currentSong.id,
              type: ArtworkType.AUDIO,
              artworkHeight: double.infinity,
              artworkWidth: double.infinity,
              quality: 100,
              artworkBorder: BorderRadius.circular(0),
              artworkFit: BoxFit.cover,
              keepOldArtwork: true,
              nullArtworkWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.grey[900]!]),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Marquee(
                  child: Text(
                    currentSong.displayNameWOExt,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Artwork
                  Container(
                    height: 320,
                    width: 340,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: QueryArtworkWidget(
                      id: currentSong.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 320,
                      artworkHeight: 320,
                      size: 1080,
                      quality: 100,
                      artworkFit: BoxFit.cover,
                      keepOldArtwork: true,
                      artworkBorder: BorderRadius.circular(10),
                      nullArtworkWidget: Container(
                        height: 300,
                        width: 300,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note,
                            size: 100, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Container(
                    height: 250,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: "Add To Playlist",
                                  content: SizedBox(
                                    height: 175,
                                    width: 225,
                                    child: Obx(() {
                                      if (controller.devicePlaylists.isEmpty) {
                                        return const Center(
                                            child: Text('No playlists found.'));
                                      }
                                      return ListView.builder(
                                        itemCount:
                                            controller.devicePlaylists.length,
                                        itemBuilder: (context, index) {
                                          final playlist =
                                              controller.devicePlaylists[index];
                                          return ListTile(
                                            title: Text(playlist.playlist),
                                            onTap: () async {
                                              await controller
                                                  .addSongToDevicePlaylist(
                                                      playlist.id,
                                                      currentSong.id);
                                              Get.back();
                                              Get.snackbar('Added',
                                                  'Song added to ${playlist.playlist}');
                                            },
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: "Create Playlist",
                                          content: TextField(
                                            controller: playlistController,
                                            decoration: const InputDecoration(
                                                hintText: "Playlist Name"),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                await controller
                                                    .createDevicePlaylist(
                                                        playlistController
                                                            .text);
                                                playlistController.clear();
                                                Get.back();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 1,
                                                  side: BorderSide.none,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  backgroundColor:
                                                      Colors.indigo),
                                              child: const Text("Create"),
                                            ),
                                          ],
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 1,
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          backgroundColor: Colors.indigo),
                                      child: const Text("Create"),
                                    ),
                                  ],
                                );
                              },
                              icon: const Icon(
                                Icons.playlist_add,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: controller.togglemute,
                              icon: Icon(
                                controller.volume.value > 0
                                    ? Iconsax.volume_high
                                    : Iconsax.volume_mute,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: controller.toggleShuffle,
                              icon: Icon(
                                controller.shuffleMode.value
                                    ? Icons.shuffle_on_outlined
                                    : Icons.shuffle_outlined,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                // Find or create "Favorites" playlist
                                final favorites = controller.devicePlaylists
                                    .firstWhereOrNull(
                                        (p) => p.playlist == "Favorites");
                                int playlistId;
                                if (favorites == null) {
                                  await controller
                                      .createDevicePlaylist("Favorites");
                                  await controller.fetchDevicePlaylist();
                                  playlistId = controller.devicePlaylists
                                      .firstWhere(
                                          (p) => p.playlist == "Favorites")
                                      .id;
                                } else {
                                  playlistId = favorites.id;
                                }
                                await controller.addSongToDevicePlaylist(
                                    playlistId, currentSong.id);
                                Get.defaultDialog(
                                    title: "Song favorited",
                                    middleText: "Added Song to Favorites");
                              },
                              icon: controller.devicePlaylists.any((p) =>
                                      p.playlist == "Favorites" &&
                                      (controller.playlistSongs[p.id]?.any(
                                              (s) => s.id == currentSong.id) ??
                                          false))
                                  ? const Icon(Icons.favorite)
                                  : const Icon(Icons.favorite_outline),
                            ),
                            IconButton(
                              onPressed: () {
                                showBpmCategories(context, currentSong);
                              },
                              icon: const Icon(
                                Icons.speed,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Artist
                        SizedBox(
                          width: 270,
                          child: Text(
                            currentSong.artist!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Slider and timing
                        StreamBuilder<Duration>(
                          stream: controller.audioPlayer.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final total = controller.audioPlayer.duration ??
                                Duration.zero;

                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(position),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text(_formatDuration(total),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                                Slider(
                                  value: controller.value.value,
                                  min: 0.0,
                                  max: controller.max.value,
                                  // max: total.inSeconds
                                  //     .toDouble()
                                  //     .clamp(0.0, double.infinity),
                                  onChanged: (value) {
                                    controller.seekTo(
                                        Duration(seconds: value.toInt()));
                                  },
                                  thumbColor: Colors.purpleAccent.shade400,
                                  activeColor: Colors.indigo,
                                  inactiveColor: Colors.grey,
                                ),
                              ],
                            );
                          },
                        ),

                        // Playback Controls
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller
                                        .setLoopMode(controller.nextLoopMode());
                                  },
                                  icon: Icon(
                                    controller.loopMode.value == LoopMode.off
                                        ? Icons.close
                                        : (controller.loopMode.value ==
                                                LoopMode.one
                                            ? Icons.repeat_one
                                            : Icons.repeat_rounded),
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.previous, size: 48),
                                  color: Colors.white,
                                  onPressed: controller.audioPlayer.hasPrevious
                                      ? () => controller.audioPlayer
                                          .seekToPrevious()
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    controller.isPlaying.value
                                        ? Iconsax.pause
                                        : Iconsax.play,
                                    size: 54,
                                  ),
                                  color: Colors.white,
                                  onPressed: controller.togglePlayPause,
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.next, size: 48),
                                  color: Colors.white,
                                  onPressed: controller.audioPlayer.hasNext
                                      ? () =>
                                          controller.audioPlayer.seekToNext()
                                      : null,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showPlaylist(context);
                                  },
                                  icon: const Icon(Iconsax.music_playlist,
                                      color: Colors.white, size: 28),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Song title
                ],
              ),
            ),
          ],
        );
      }
    });
  }

  String _formatDuration(Duration duration) {
    final min = duration.inMinutes.toString().padLeft(2, '0');
    final sec = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }
}

void showPlaylist(BuildContext context) {
  var controller = Get.find<PlayerController>();

  showModalBottomSheet(
      backgroundColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: Obx(
            () {
              if (controller.currentPlaylist.isEmpty) {
                return const Center(
                  child: Text("No songs in the playlist",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                );
              } else {
                return ListView.builder(
                  itemCount: controller.currentPlaylist.length,
                  itemBuilder: (context, index) {
                    final song = controller.currentPlaylist[index];
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.circular(6),
                        artworkHeight: 50,
                        artworkWidth: 50,
                        artworkFit: BoxFit.cover,
                        nullArtworkWidget: Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note,
                              size: 25, color: Colors.white),
                        ),
                      ),
                      title: Text(song.displayNameWOExt,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(song.artist ?? "Unknown Artist",
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        controller.setPlaylist(controller.currentPlaylist);
                        controller.playPlaylist(
                            controller.currentPlaylist, index);
                        Get.back();
                      },
                    );
                  },
                );
              }
            },
          ),
        );
      });
}

void showBpmCategories(BuildContext context, SongModel currentSong) {
  var controller = Get.find<PlayerController>();

  showModalBottomSheet(
    backgroundColor: Colors.black.withOpacity(0.8),
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How does this song make you feel?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.getBpmCategories().map((category) {
                return Obx(() {
                  final isSelected =
                      controller.getSongBpmCategory(currentSong.id) == category;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.green : Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      controller.assignSongToBpmCategory(currentSong, category);
                      Get.back();
                      Get.snackbar(
                        'BPM Category Updated',
                        '${currentSong.displayNameWOExt} assigned to $category',
                        colorText: Colors.white,
                        backgroundColor: Colors.green.withOpacity(0.7),
                      );
                    },
                    child: Text(category),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}
