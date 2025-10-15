import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/screens/now_playing_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  //bool isMiniPlayerVisible = false; // Tracks the visibility of the mini player

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Obx(() {
                if (controller.currentPlaylist.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (context) {
                      final songList = controller.currentPlaylist;
                      return ListView.builder(
                        itemCount: songList.length,
                        itemBuilder: (context, index) {
                          final song = songList[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ListTile(
                              leading: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(6),
                                artworkHeight: 50,
                                artworkWidth: 50,
                                keepOldArtwork: true,
                                artworkFit: BoxFit.cover,
                                nullArtworkWidget: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note,
                                      size: 25, color: Colors.white),
                                ),
                              ),
                              title: Text(
                                song.displayNameWOExt,
                              ),
                              subtitle: Text(song.artist ?? "Unknown Artist"),
                              onTap: () {
                                if (controller.currentSongRx.value != null &&
                                    controller.currentSongRx.value!.id ==
                                        song.id) {
                                  // If the song is already playing, do nothing
                                  Get.to(() => NowPlayingScreen());
                                } else if (controller.currentSongRx.value !=
                                        null &&
                                    controller.currentSongRx.value!.id !=
                                        song.id) {
                                  // If a different song is playing, stop it first
                                  controller.stop();
                                  controller.playSong(song);
                                  controller.setPlaylist(songList,
                                      startIndex: index);
                                  Get.to(() => NowPlayingScreen());
                                } else {
                                  controller.playSong(song);
                                  controller.setPlaylist(songList,
                                      startIndex: index);
                                  Get.to(() => NowPlayingScreen());
                                }
                              },
                            ),
                          );
                        },
                      );
                    }),
                  );
                }
              }),
            ),

            // Mini Player
            // MiniPlayerWidget(
            //     isMiniPlayerVisible: isMiniPlayerVisible,
            //     controller: controller),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 100.0),
        //   child: FloatingActionButton(
        //     onPressed: () {
        //       setState(() {
        //         isMiniPlayerVisible = !isMiniPlayerVisible; // Toggle visibility
        //       });
        //     },
        //     child: const Icon(Iconsax.smileys),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({
    super.key,
    required this.isMiniPlayerVisible,
    required this.controller,
  });

  final bool isMiniPlayerVisible;
  final PlayerController controller;

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Full rotation duration
    )..repeat(); // Start spinning immediately
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    bool isSwiping = false; // Track if the mini player is being swiped
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOut,
      bottom: widget.isMiniPlayerVisible ? 20 : -100, // Slide in/out
      left: 20,
      right: 20,
      child: GestureDetector(
        onPanStart: (_) {
          isSwiping = false;
        },
        onPanUpdate: (details) {
          // Swiping right
          if (!isSwiping && details.delta.dx > 0) {
            isSwiping = true;
            widget.controller.audioPlayer.seekToPrevious();
          }

          // Swiping left
          if (!isSwiping && details.delta.dx < 0) {
            isSwiping = true;
            widget.controller.audioPlayer.seekToNext();
          }

          // Swiping down
          if (!isSwiping && details.delta.dy > 0) {
            isSwiping = true;
            widget.controller.stop();
          }
        },
        onTap: () {
          // Navigate to NowPlayingScreen when the mini player is tapped
          Get.to(() => NowPlayingScreen(), transition: Transition.downToUp);
        },
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            color: isDarkTheme ? Colors.grey[900] : Colors.white, // Adapt color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkTheme
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Spinning Artwork
                Obx(() {
                  final currentSong = widget.controller.currentSongRx.value;
                  if (widget.controller.isPlaying.value) {
                    _rotationController.repeat(); // Start spinning
                  } else {
                    _rotationController.stop(); // Stop spinning
                  }
                  return RotationTransition(
                    turns: _rotationController,
                    child: QueryArtworkWidget(
                      id: currentSong?.id ?? 0,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 60,
                      artworkWidth: 60,
                      keepOldArtwork: true,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),
                        child: const Icon(Icons.music_note,
                            size: 25, color: Colors.white),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 10),

                // Song Info
                Expanded(
                  child: Obx(() {
                    final currentSong = widget.controller.currentSongRx.value;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                          child: Text(
                            currentSong?.displayNameWOExt ?? "No Song",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          currentSong?.artist ?? "Unknown Artist",
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  }),
                ),

                // Play/Pause Button
                Obx(() {
                  return IconButton(
                    icon: Icon(
                      widget.controller.isPlaying.value
                          ? Iconsax.pause
                          : Iconsax.play,
                      color: Colors.white,
                    ),
                    onPressed: widget.controller.togglePlayPause,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
