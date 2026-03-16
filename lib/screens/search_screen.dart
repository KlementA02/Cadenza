import 'package:cadenza/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayerController());
    final showSearchbar = false.obs;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Songs'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          // Show Search Bar if toggled
          Obx(() => showSearchbar.value
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedContainer(
                    height: showSearchbar.value ? 50 : 0,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    child: showSearchbar.value
                        ? TextField(
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: controller.searchSongs,
                          )
                        : null,
                  ),
                )
              : const SizedBox.shrink()),

          // Songs List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              final songsToDisplay = controller.searchResults.isNotEmpty
                  ? controller.searchResults
                  : controller.currentPlaylist;

              if (songsToDisplay.isEmpty) {
                return const Center(
                  child: Text(
                    "No songs found",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  itemCount: songsToDisplay.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 200,
                  ),
                  itemBuilder: (context, index) {
                    final song = songsToDisplay[index];

                    return GestureDetector(
                      onTap: () {
                        if (song.uri != null) {
                          controller.playSong(song);
                        } else {
                          Get.snackbar("Error", "Song has no URI");
                        }
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(8),
                                artworkHeight: 120,
                                artworkWidth: 120,
                                nullArtworkWidget: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    size: 50,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                song.displayNameWOExt,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                song.artist ?? "Unknown Artist",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 175.0),
        child: FloatingActionButton(
          heroTag: 'searchFAB',
          onPressed: () => showSearchbar.toggle(),
          child: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}
