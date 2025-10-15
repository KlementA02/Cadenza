import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';

class CadenzaAudioHandler extends BaseAudioHandler {
  final audioQuery = OnAudioQuery();

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    try {
      // Try to get the artwork for the current song
      final artwork = await audioQuery.queryArtwork(
        int.parse(mediaItem.id),
        ArtworkType.AUDIO,
        size: 500, // Size of the artwork in the notification
        quality: 100,
      );

      if (artwork != null) {
        // Create a new MediaItem with the artwork
        final updatedMediaItem = mediaItem.copyWith(
          artUri: Uri.dataFromBytes(artwork, mimeType: 'image/png'),
        );
        super.mediaItem.add(updatedMediaItem);
      } else {
        super.mediaItem.add(mediaItem);
      }
    } catch (e) {
      // Fallback to the original media item if artwork loading fails
      super.mediaItem.add(mediaItem);
    }
  }
}
