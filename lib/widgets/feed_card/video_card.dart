import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/feed_item.dart';

/// A full-screen video card for the feed.
/// Tap-to-play, no autoplay, sound off by default.
class VideoCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback? onNoteToggle;
  final bool showNote;

  const VideoCard({
    super.key,
    required this.item,
    this.onNoteToggle,
    this.showNote = false,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = false;
  late AnimationController _controlsFadeController;

  @override
  void initState() {
    super.initState();
    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.item.content));
      await _videoController!.initialize();
      _videoController!.setVolume(0); // Sound off by default

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: true,
        showControls: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _showControls = true;
    });

    _controlsFadeController.forward(from: 0);

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _videoController!.value.isPlaying) {
        setState(() => _showControls = false);
        _controlsFadeController.reverse();
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null) return;
    setState(() {
      _videoController!
          .setVolume(_videoController!.value.volume > 0 ? 0 : 1);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _controlsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            if (_isInitialized && _chewieController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              )
            else if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load video',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),

            // Play/Pause overlay
            if (_isInitialized && !_videoController!.value.isPlaying)
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

            // Controls overlay (fade in/out)
            if (_showControls && _isInitialized)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: FadeTransition(
                  opacity: _controlsFadeController,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _videoController!.value.volume > 0
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Content type indicator
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Private note icon
            if (widget.item.note != null && widget.item.note!.isNotEmpty)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: widget.onNoteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.showNote
                              ? Icons.sticky_note_2
                              : Icons.sticky_note_2_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ),
                    ),
                    if (widget.showNote) ...[
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.item.note!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
