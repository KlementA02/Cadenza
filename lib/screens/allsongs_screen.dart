import 'dart:ui';

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
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // Order Type Bar
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => Row(
                          children: [
                            _buildOrderChip(
                              'Title A-Z',
                              OrderType.ASC_OR_SMALLER,
                              controller,
                            ),
                            _buildOrderChip(
                              'Title Z-A',
                              OrderType.DESC_OR_GREATER,
                              controller,
                            ),
                            _buildOrderChip2(
                              'Artist',
                              SongSortType.ARTIST,
                              controller,
                            ),
                            _buildOrderChip2(
                              'Album',
                              SongSortType.ALBUM,
                              controller,
                            ),
                            _buildOrderChip2(
                              'Duration',
                              SongSortType.DURATION,
                              controller,
                            ),
                            _buildOrderChip2(
                              'Date Added',
                              SongSortType.DATE_ADDED,
                              controller,
                            ),
                            _buildOrderChip2(
                              'Size',
                              SongSortType.SIZE,
                              controller,
                            ),
                          ],
                        )),
                  ),
                ),
                // Existing ListView
                Expanded(
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
                            controller: _scrollController,
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
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      child: Icon(Icons.music_note,
                                          size: 25,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                  ),
                                  title: Text(
                                    song.displayNameWOExt,
                                  ),
                                  subtitle:
                                      Text(song.artist ?? "Unknown Artist"),
                                  onTap: () {
                                    if (controller.currentSongRx.value !=
                                            null &&
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
              ],
            ),
            // Your existing mini player widget
          ],
        ),
      ),
    );
  }

  Widget _buildOrderChip(
      String label, OrderType type, PlayerController controller) {
    final isSelected = controller.currentOrderType.value == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
          ),
        ),
        onSelected: (_) => controller.changeOrderType(type),
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOrderChip2(
      String label, SongSortType type, PlayerController controller) {
    final isSelected = controller.currentSortType.value == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
          ),
        ),
        onSelected: (_) => controller.changeSortType(type),
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.15),
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: isDarkTheme
            //         ? Colors.black.withOpacity(0.5)
            //         : Colors.grey.withOpacity(0.5),
            //     blurRadius: 10,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Obx(() {
                    final currentSong = widget.controller.currentSongRx.value;
                    return QueryArtworkWidget(
                      id: currentSong?.id ?? 0,
                      type: ArtworkType.AUDIO,
                      artworkHeight: double.infinity,
                      artworkWidth: double.infinity,
                      artworkFit: BoxFit.cover,
                      artworkBorder: BorderRadius.circular(12),
                      keepOldArtwork: true,
                      nullArtworkWidget: Container(
                        color: isDarkTheme ? Colors.grey[900] : Colors.white,
                      ),
                    );
                  }),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(),
                  child: Container(
                    color: isDarkTheme
                        ? Colors.black.withOpacity(0.7)
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Spinning Artwork
                      Obx(() {
                        final currentSong =
                            widget.controller.currentSongRx.value;
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
                          final currentSong =
                              widget.controller.currentSongRx.value;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Marquee(
                                child: Text(
                                  currentSong?.displayNameWOExt ?? "No Song",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
