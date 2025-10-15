import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerController extends GetxController {
  late AudioPlayer audioPlayer;
  final audioQuery = OnAudioQuery();
  final playIndex = 0.obs;
  final isPlaying = false.obs;

  final Rx<SongModel?> currentSongRx = Rx<SongModel?>(null);

  var isLoading = false.obs;
  var isLoading1 = false.obs;
  var shuffleMode = false.obs;

  var duration = ''.obs;
  var position = ''.obs;

  var value = 0.0.obs;
  var max = 0.0.obs;
  var volume = 1.0.obs;
  var albumId = 0.obs;

  var loopMode = LoopMode.off.obs;

  var devicePlaylists = <PlaylistModel>[].obs;
  var playlistSongs = <int, List<SongModel>>{}.obs;

  RxList<SongModel> currentPlaylist = <SongModel>[].obs;
  RxList<SongModel> searchResults = <SongModel>[].obs;

  RxList<AlbumModel> currentAlbum = <AlbumModel>[].obs;

  // BPM Categories
  final Map<String, RxList<SongModel>> bpmCategories = {
    '✨Chill Vibes': RxList<SongModel>([]),
    '🌊Groovy Flow': RxList<SongModel>([]),
    '🔥Energy Boost': RxList<SongModel>([]),
    '⚡Hype Mode': RxList<SongModel>([]),
  };

  // Store song BPM assignments
  final songBpmCategory = <int, String>{}.obs; // Map<songId, categoryName>

  // Store recommendations
  final recommendations = <String, RxList<SongModel>>{}.obs;

  // Add to PlayerController
  final playCounts = <int, int>{}.obs; // songId -> play count
  final lastPlayed = <int, DateTime>{}.obs; // songId -> last played

  // Add these constants for storage keys
  static const String _bpmCategoriesKey = 'bpm_categories';
  static const String _songBpmCategoryKey = 'song_bpm_category';

  void initAudioPlayer() {
    try {
      // Player state
      audioPlayer.playerStateStream.listen((playerState) {
        isPlaying.value = playerState.playing;

        // Handle completion
        if (playerState.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          if (loopMode.value == LoopMode.off) {
            audioPlayer.seek(Duration.zero);
          }
        }
      }, onError: (error) {
        print("Error in playerStateStream: $error");
      });

      // Position
      audioPlayer.positionStream.listen((position) {
        this.position.value = formatDuration(position);
        value.value = position.inSeconds.toDouble();
      }, onError: (error) {
        print("Error in positionStream: $error");
      });

      // Duration
      audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          this.duration.value = formatDuration(duration);
          max.value = duration.inSeconds.toDouble();
        }
      }, onError: (error) {
        print("Error in durationStream: $error");
      });

      // Current song
      audioPlayer.currentIndexStream.listen((index) {
        if (index != null) {
          playIndex.value = index;
          final sequence = audioPlayer.sequence;
          if (sequence != null && index < sequence.length) {
            final tag = sequence[index].tag;
            if (tag is MediaItem) {
              final extras = tag.extras;
              if (extras != null) {
                currentSongRx.value = SongModel(extras);
              } else {
                // Fallback: create a minimal SongModel (may still cause issues if required fields are missing)
                currentSongRx.value = SongModel({
                  'id': int.tryParse(tag.id) ?? 0,
                  'title': tag.title,
                  'artist': tag.artist,
                  'album': tag.album,
                  'uri': '', // fallback
                  'duration': tag.duration?.inMilliseconds ?? 0,
                });
              }
            }
          }
        }
      }, onError: (error) {
        print("Error in currentIndexStream: $error");
      });
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  Future<void> checkPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;

      final perm = sdk >= 33 ? Permission.audio : Permission.storage;

      var status = await perm.status;
      if (status.isGranted) {
        await fetchSongs();
      } else if (status.isDenied) {
        var result = await perm.request();
        if (result.isGranted) {
          await fetchSongs();
        } else if (result.isPermanentlyDenied) {
          // Show rationale and Open App Settings
          Get.defaultDialog(
            title: "Permission Required",
            content: const Text("Enable permission in settings."),
            confirm: ElevatedButton(
              onPressed: () {
                openAppSettings();
                Get.back();
              },
              child: const Text("Open Settings"),
            ),
          );
        }
      }
    }
  }

  Future<void> fetchSongs() async {
    if (currentPlaylist.isNotEmpty) {
      if (kDebugMode) print("fetchSongs skipped: Playlist already populated");
      return;
    }
    if (kDebugMode) print("fetchSongs called: Fetching songs from device");

    isLoading.value = true;
    try {
      var fetchedSongs = await audioQuery.querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );
      currentPlaylist.assignAll(fetchedSongs);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAlbums() async {
    if (currentAlbum.isNotEmpty) {
      if (kDebugMode) print("fetchAlbums skipped: Album already populated");
      return;
    }
    if (kDebugMode) print("fetchAlbums called: Fetching albums from device");

    isLoading.value = true;
    try {
      var fetchedAlbums = await audioQuery.queryAlbums(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      currentAlbum.assignAll(fetchedAlbums);
    } finally {
      isLoading1.value = false;
    }
  }

  Future<void> fetchSongFromAlbum(int albumId) async {
    if (currentPlaylist.isNotEmpty) {
      if (kDebugMode) {
        print("fetchSongFromAlbum skipped: Playlist already populated");
      }
      return;
    }
    if (kDebugMode) {
      print("fetchSongFromAlbum called: Fetching songs from album");
    }

    isLoading.value = true;
    try {
      var songs = await audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM,
        albumId,
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      currentPlaylist.assignAll(songs);
    } finally {
      isLoading.value = false;
    }
  }

//Controls having to do with playlists

  // Fetch device playlists
  Future<void> fetchDevicePlaylist() async {
    isLoading.value = true;
    try {
      final playlists = await audioQuery.queryPlaylists();
      devicePlaylists.assignAll(playlists);

      for (var playlist in playlists) {
        final songs = await audioQuery.queryAudiosFrom(
            AudiosFromType.PLAYLIST, playlist.id);
        playlistSongs[playlist.id] = songs;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new device playlist
  Future<void> createDevicePlaylist(String name) async {
    final result = await audioQuery.createPlaylist(name);
    if (result) {
      await fetchDevicePlaylist();
    }
  }

  // Add a song to a device playlist
  Future<void> addSongToDevicePlaylist(int playlistId, int songId) async {
    final result = await audioQuery.addToPlaylist(playlistId, songId);
    if (result) {
      final songs = await audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlistId,
      );
      playlistSongs[playlistId] = songs;
    }
  }

  // Remove a song from a device playlist
  Future<void> removeSongFromDevicePlaylist(int playlistId, int songId) async {
    final result = await audioQuery.removeFromPlaylist(playlistId, songId);
    if (result) {
      final songs = await audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        playlistId,
      );
      playlistSongs[playlistId] = songs;
    }
  }

  // Delete a device playlist
  Future<void> deleteDevicePlaylist(int playlistId) async {
    final result = await audioQuery.removePlaylist(playlistId);
    if (result) {
      devicePlaylists.removeWhere((p) => p.id == playlistId);
      playlistSongs.remove(playlistId);
    }
  }

  Future<void> renameDevicePlaylist(int playlistId, String newName) async {
    try {
      // Rename the playlist using the audioQuery API
      final result = await audioQuery.renamePlaylist(playlistId, newName);

      if (result) {
        // Update the playlist in the local list
        final playlistIndex =
            devicePlaylists.indexWhere((playlist) => playlist.id == playlistId);
        if (playlistIndex != -1) {
          final oldPlaylist = devicePlaylists[playlistIndex];
          devicePlaylists[playlistIndex] = PlaylistModel(
            oldPlaylist.getMap
              ..['name'] = newName, // Update the name in the map

            // Add other fields as necessary if PlaylistModel has more fields
          );
        }
      } else {
        if (kDebugMode) {
          print("Failed to rename playlist with ID: $playlistId");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error renaming playlist: $e");
      }
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Set a new playlist and start playing from index
  Future<void> setPlaylist(List<SongModel> songs, {int startIndex = 0}) async {
    if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) {
      if (kDebugMode) print("Invalid playlist or start index");
      return;
    }

    try {
      // Properly dispose of the current audio source
      await audioPlayer.stop();

      // Map songs to audio sources with metadata
      final audioSources = songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? 'Unknown Album',
            title: song.displayNameWOExt,
            artist: song.artist ?? 'Unknown Artist',
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.parse('asset:///assets/default_artwork.png'),
            extras: Map<String, dynamic>.from(song.getMap), // <-- full map here
          ),
        );
      }).toList();

      // Create playlist with proper error handling
      final playlist = ConcatenatingAudioSource(
        children: audioSources,
        useLazyPreparation: true, // Add lazy loading
      );

      // Set the audio source with proper error handling
      await audioPlayer
          .setAudioSource(
        playlist,
        initialIndex: startIndex,
        preload: false, // Disable preloading to prevent interruption
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Loading playlist timed out');
        },
      );

      // Update current song
      currentSongRx.value = songs[startIndex];
      playIndex.value = startIndex;

      // Start playback
      await audioPlayer.play();
    } on TimeoutException {
      if (kDebugMode) {
        print("Playlist loading timed out");
      }
      Get.snackbar(
        'Error',
        'Playlist loading timed out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error in setPlaylist: $e");
      }
      Get.snackbar(
        'Error',
        'Could not play the playlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update playSong method
  Future<void> playSong(SongModel song) async {
    try {
      await audioPlayer.stop();
      final mediaItem = MediaItem(
        id: song.id.toString(),
        album: song.album ?? 'Unknown Album',
        title: song.displayNameWOExt,
        artist: song.artist ?? 'Unknown Artist',
        duration: Duration(milliseconds: song.duration ?? 0),
        artUri: Uri.parse('asset:///assets/default_artwork.png'),
        extras: Map<String, dynamic>.from(song.getMap),
      );
      final source = AudioSource.uri(Uri.parse(song.uri!), tag: mediaItem);
      await audioPlayer.setAudioSource(source, preload: false);
      currentSongRx.value = song;
      await audioPlayer.play();

      // Track play count and last played
      playCounts[song.id] = (playCounts[song.id] ?? 0) + 1;
      lastPlayed[song.id] = DateTime.now();

      generateRecommendations(song);
    } catch (e) {
      if (kDebugMode) print("Error playing song: $e");
      Get.snackbar(
        'Error',
        'Could not play "${song.displayNameWOExt}"',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add this method to initialize background playback
  static Future<void> initAudioService() async {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.example.cadenza.channel.audio',
        androidNotificationChannelName: 'Cadenza Music',
        androidNotificationOngoing: false, // Changed to false
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: true, // Changed to true
        notificationColor: const Color(0xFF2196f3),
        androidNotificationIcon: 'mipmap/ic_launcher',
        preloadArtwork: true,
      );
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      rethrow;
    }
  }

  // Update the playSong method
  Future<void> playSong1(SongModel song) async {
    try {
      final source = AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? 'Unknown Album',
          title: song.displayNameWOExt,
          artist: song.artist ?? 'Unknown Artist',
          artUri: Uri.parse(
              'asset:///assets/default_artwork.png'), // Default artwork
          extras: {'songModel': song.getMap},
        ),
      );

      await audioPlayer.setAudioSource(source);
      currentSongRx.value = song;
      await audioPlayer.play();
      generateRecommendations(song);
    } catch (e) {
      if (kDebugMode) {
        print("Error playing song: $e");
      }
    }
  }

// Add this helper method to get artwork URI
  Future<Uri> _getArtworkUri(int songId) async {
    try {
      final artworkFile = await audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: 500,
        quality: 100,
      );

      if (artworkFile != null) {
        // Since artworkFile is Uint8List, you can't get a path; return default artwork asset URI
        return Uri.parse('asset:///assets/default_artwork.png');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting artwork: $e");
      }
    }

    // Return default artwork if no artwork found
    return Uri.parse('asset:///assets/default_artwork.png');
  }

  void play() => audioPlayer.play();
  void pause() => audioPlayer.pause();
  void stop() => audioPlayer.stop();
  void togglePlayPause() => isPlaying.value ? pause() : play();

  void setVolume(double volume) {
    audioPlayer.setVolume(volume);
    this.volume.value = volume;
  }

  void setLoopMode(LoopMode mode) {
    audioPlayer.setLoopMode(mode);
    loopMode.value = mode;
  }

  void togglemute() {
    if (volume.value > 0) {
      setVolume(0);
    } else {
      setVolume(1);
    }
  }

  void toggleShuffle() {
    final enable = !shuffleMode.value;
    if (enable) {
      audioPlayer.shuffle();
    }
    audioPlayer.setShuffleModeEnabled(enable);
    shuffleMode.value = enable;
  }

  void searchSongs(String query) async {
    if (query.isEmpty) {
      // If the query is empty, clear search results
      searchResults.clear();
      return;
    }

    // Filter songs in the current playlist based on the query
    final results = currentPlaylist.where((song) {
      final title = song.displayNameWOExt.toLowerCase();
      final artist = (song.artist ?? "").toLowerCase();
      final searchQuery = query.toLowerCase();

      return title.contains(searchQuery) || artist.contains(searchQuery);
    }).toList();

    // Update the search results
    searchResults.assignAll(results);
  }

  LoopMode nextLoopMode() {
    switch (loopMode.value) {
      case LoopMode.off:
        loopMode.value = LoopMode.one;
        break;
      case LoopMode.one:
        loopMode.value = LoopMode.all;
        break;
      case LoopMode.all:
        loopMode.value = LoopMode.off;
        break;
    }
    audioPlayer.setLoopMode(loopMode.value);
    return loopMode.value;
  }

  void seekTo(Duration position) => audioPlayer.seek(position);

  SongModel? get currentSongValue => currentSongRx.value;

  // Get currently playing song
  SongModel? get currentSong {
    final tag =
        audioPlayer.sequence?.elementAt(audioPlayer.currentIndex ?? 0).tag;
    return tag is SongModel ? tag : null;
  }

  // Get the BPM category for a given song ID
  String? getSongBpmCategory(int songId) {
    return songBpmCategory[songId];
  }

  // Get all songs in a given BPM category
  List<SongModel> getSongsInBpmCategory(String category) {
    return bpmCategories[category]?.toList() ?? [];
  }

  // Get recommendations based on BPM categories and artist similarities
  void generateRecommendations(SongModel? currentSong) {
    recommendations.clear();

    // Most Played
    final mostPlayed = currentPlaylist.toList()
      ..sort(
          (a, b) => (playCounts[b.id] ?? 0).compareTo(playCounts[a.id] ?? 0));
    recommendations['Most Played'] =
        RxList<SongModel>(mostPlayed.take(10).toList());

    // Recently Played
    final recentlyPlayed = currentPlaylist.toList()
      ..sort((a, b) => (lastPlayed[b.id]?.millisecondsSinceEpoch ?? 0)
          .compareTo(lastPlayed[a.id]?.millisecondsSinceEpoch ?? 0));
    recommendations['Recently Played'] =
        RxList<SongModel>(recentlyPlayed.take(10).toList());

    // Same Artist or Album as current song
    if (currentSong != null) {
      final sameArtist = currentPlaylist
          .where((s) =>
              s.id != currentSong.id &&
              (s.artist?.toLowerCase() == currentSong.artist?.toLowerCase()))
          .toList();
      if (sameArtist.isNotEmpty) {
        recommendations['More from ${currentSong.artist ?? "Artist"}'] =
            RxList<SongModel>(sameArtist.take(10).toList());
      }

      final sameAlbum = currentPlaylist
          .where((s) =>
              s.id != currentSong.id &&
              (s.album?.toLowerCase() == currentSong.album?.toLowerCase()))
          .toList();
      if (sameAlbum.isNotEmpty) {
        recommendations['More from ${currentSong.album ?? "Album"}'] =
            RxList<SongModel>(sameAlbum.take(10).toList());
      }
    }
  }

  // Get the list of BPM category names
  List<String> getBpmCategories() {
    return bpmCategories.keys.toList();
  }

  // Get adjacent BPM categories for broader recommendations
  List<String> getAdjacentCategories(String currentCategory) {
    final categories = getBpmCategories();
    final currentIndex = categories.indexOf(currentCategory);
    final adjacentCategories = <String>[];

    // Add previous category if it exists
    if (currentIndex > 0) {
      adjacentCategories.add(categories[currentIndex - 1]);
    }

    // Add next category if it exists
    if (currentIndex < categories.length - 1) {
      adjacentCategories.add(categories[currentIndex + 1]);
    }

    return adjacentCategories;
  }

  // Get top recommendations (limited to 5 songs per category)
  Map<String, List<SongModel>> getTopRecommendations() {
    final topRecommendations = <String, List<SongModel>>{};

    recommendations.forEach((category, songs) {
      // Limit to 5 songs per category and shuffle for variety
      final limitedSongs = songs.toList()..shuffle();
      topRecommendations[category] = limitedSongs.take(5).toList();
    });

    return topRecommendations;
  }

  // Get personalized recommendations based on listening history
  List<SongModel> getPersonalizedRecommendations(SongModel currentSong) {
    final recommendations = <SongModel>[];
    final currentCategory = getSongBpmCategory(currentSong.id);

    if (currentCategory != null) {
      // Get songs from the same BPM category
      final sameCategorySongs = getSongsInBpmCategory(currentCategory)
          .where((song) => song.id != currentSong.id)
          .toList();

      // Get songs by the same artist
      final sameArtistSongs = currentPlaylist
          .where((song) =>
              song.id != currentSong.id &&
              song.artist?.toLowerCase() == currentSong.artist?.toLowerCase())
          .toList();

      // Combine and shuffle recommendations
      recommendations.addAll(sameCategorySongs);
      recommendations.addAll(sameArtistSongs);
      recommendations.shuffle();

      // Limit to 10 recommendations
      return recommendations.take(10).toList();
    }

    return [];
  }

  Future<void> playPlaylist(List<SongModel> songs, int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) {
      if (kDebugMode) print("Invalid playlist or index");
      return;
    }

    try {
      await audioPlayer.stop();

      final sources = songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? 'Unknown Album',
            title: song.displayNameWOExt,
            artist: song.artist ?? 'Unknown Artist',
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.parse('asset:///assets/default_artwork.png'),
            extras: Map<String, dynamic>.from(song.getMap),
          ),
        );
      }).toList();

      final playlist = ConcatenatingAudioSource(children: sources);

      await audioPlayer.setAudioSource(playlist, initialIndex: index);
      currentSongRx.value = songs[index];
      await audioPlayer.play();
    } catch (e) {
      if (kDebugMode) print("Error in playPlaylist: $e");
      Get.snackbar(
        'Error',
        'Could not play the playlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add these methods for persistence
  Future<void> saveBpmCategories() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert bpmCategories to a saveable format
    final Map<String, List<Map<String, dynamic>>> categoriesMap = {};
    bpmCategories.forEach((category, songs) {
      categoriesMap[category] =
          songs.map((song) => Map<String, dynamic>.from(song.getMap)).toList();
    });

    // Save bpmCategories
    await prefs.setString(_bpmCategoriesKey, jsonEncode(categoriesMap));

    // Save songBpmCategory
    final Map<String, String> songCategoryMap = {};
    songBpmCategory.forEach((songId, category) {
      songCategoryMap[songId.toString()] = category;
    });
    await prefs.setString(_songBpmCategoryKey, jsonEncode(songCategoryMap));
  }

  Future<void> loadBpmCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load and restore bpmCategories
      final categoriesString = prefs.getString(_bpmCategoriesKey);
      if (categoriesString != null) {
        final Map<String, dynamic> categoriesMap = jsonDecode(categoriesString);

        categoriesMap.forEach((category, songsData) {
          final List<dynamic> songsList = songsData as List;
          final songs = songsList.map((songData) {
            return SongModel(songData as Map<String, dynamic>);
          }).toList();
          bpmCategories[category] = RxList<SongModel>(songs);
        });
      }

      // Load and restore songBpmCategory
      final songCategoryString = prefs.getString(_songBpmCategoryKey);
      if (songCategoryString != null) {
        final Map<String, dynamic> songCategoryMap =
            jsonDecode(songCategoryString);
        songCategoryMap.forEach((songId, category) {
          songBpmCategory[int.parse(songId)] = category as String;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading BPM categories: $e");
      }
    }
  }

  // Update the assignSongToBpmCategory method
  void assignSongToBpmCategory(SongModel song, String category) {
    // Remove song from current category if it exists
    final currentCategory = songBpmCategory[song.id];
    if (currentCategory != null) {
      bpmCategories[currentCategory]?.remove(song);
    }

    // Assign to new category
    if (bpmCategories.containsKey(category)) {
      bpmCategories[category]?.add(song);
      songBpmCategory[song.id] = category;

      // Save changes to persistent storage
      saveBpmCategories();
    }
  }

  // Update onInit to load saved categories
  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer(); // Initialize here
    loadBpmCategories();
    checkPermission();
    initAudioPlayer();
    fetchSongs();
    fetchAlbums();
    fetchDevicePlaylist();
    generateRecommendations(null);
  }

  // Update onClose to save categories
  @override
  void onClose() {
    saveBpmCategories(); // Save categories before closing
    audioPlayer.dispose();
    super.onClose();
  }
}
