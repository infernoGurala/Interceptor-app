import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../models/feed_item.dart';

/// A full-screen image card for the feed.
/// Supports pinch-to-zoom via PhotoView.
class ImageCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onNoteToggle;
  final bool showNote;

  const ImageCard({
    super.key,
    required this.item,
    this.onNoteToggle,
    this.showNote = false,
  });

  ImageProvider _resolveImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImageProvider(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image with pinch-to-zoom
          PhotoView(
            imageProvider: _resolveImageProvider(item.content),
            backgroundDecoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
                value: event != null && event.expectedTotalBytes != null
                    ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
                    : null,
              ),
            ),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_rounded,
                      color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load image',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
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
                Icons.image_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),

          // Private note
          if (item.note != null && item.note!.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: onNoteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showNote
                            ? Icons.sticky_note_2
                            : Icons.sticky_note_2_outlined,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ),
                  ),
                  if (showNote) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.note!,
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
    );
  }
}
