import 'package:cadenza/controllers/player_controller.dart';
import 'package:cadenza/screens/now_playing_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class PlaylistSongsPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistSongsPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistSongsPage> createState() => _PlaylistSongsPageState();
}

class _PlaylistSongsPageState extends State<PlaylistSongsPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final controller = Get.find<PlayerController>();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongsFromPlaylist();
  }

  Future<void> _loadSongsFromPlaylist() async {
    try {
      final songs = await _audioQuery.queryAudiosFrom(
          AudiosFromType.PLAYLIST, widget.playlistId);
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
        centerTitle: true,
        actions: [
          // Add play all button
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              if (_songs.isNotEmpty) {
                controller.playPlaylist(_songs, 0);
                Get.to(() => NowPlayingScreen());
              }
            },
          ),
          // Add shuffle play button
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              if (_songs.isNotEmpty) {
                final shuffledSongs = List<SongModel>.from(_songs)..shuffle();
                controller.playPlaylist(shuffledSongs, 0);
                Get.to(() => NowPlayingScreen());
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? const Center(child: Text('No songs found in this playlist.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _songs.length,
                  itemBuilder: (_, index) {
                    final song = _songs[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkHeight: 50,
                          artworkWidth: 50,
                          nullArtworkWidget: Container(
                            height: 50,
                            width: 50,
                            color: isDarkTheme
                                ? Colors.grey[850]
                                : Colors.grey[200],
                            child: Icon(
                              Icons.music_note,
                              color:
                                  isDarkTheme ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ),
                        title: Text(
                          song.displayNameWOExt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () =>
                              _showSongOptions(context, song, index),
                        ),
                        onTap: () {
                          // Set the playlist and play from the tapped song
                          controller.playPlaylist(_songs, index);
                          Get.to(() => NowPlayingScreen());
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showSongOptions(BuildContext context, SongModel song, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              controller.playPlaylist(_songs, index);
              Get.to(() => NowPlayingScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_remove),
            title: const Text('Remove from playlist'),
            onTap: () async {
              Navigator.pop(context);
              await controller.removeSongFromDevicePlaylist(
                  widget.playlistId, song.id);
              _loadSongsFromPlaylist(); // Refresh the list
            },
          ),
          if (controller.bpmCategories.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Set BPM Category'),
              onTap: () {
                Navigator.pop(context);
                _showBpmCategorySelection(context, song);
              },
            ),
        ],
      ),
    );
  }

  void _showBpmCategorySelection(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select BPM Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.bpmCategories.length,
              itemBuilder: (context, index) {
                final category = controller.getBpmCategories()[index];
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    controller.assignSongToBpmCategory(song, category);
                    Navigator.pop(context);
                    Get.snackbar(
                      'Category Updated',
                      '${song.displayNameWOExt} added to $category',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
