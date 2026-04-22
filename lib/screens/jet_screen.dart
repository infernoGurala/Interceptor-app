import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/feed_item.dart';
import '../providers/providers.dart';
import '../utils/connectivity.dart';

/// The upload screen where users add content to their feed.
class JetScreen extends ConsumerStatefulWidget {
  const JetScreen({super.key});

  @override
  ConsumerState<JetScreen> createState() => _JetScreenState();
}

class _JetScreenState extends ConsumerState<JetScreen> {
  ContentType _selectedType = ContentType.text;
  final _linkController = TextEditingController();
  final _textController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isUploading = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      String content;

      if (_selectedType == ContentType.text) {
        // Text/markdown — direct content
        if (_textController.text.trim().isEmpty) {
          throw Exception('Please enter some content');
        }
        content = _textController.text.trim();
      } else {
        // Image/Video — process link
        if (_linkController.text.trim().isEmpty) {
          throw Exception('Please paste a link');
        }

        setState(() => _statusMessage = 'Extracting media URL...');

        // Cobalt: extract raw URL from platform link
        final cobalt = ref.read(cobaltServiceProvider);
        final cobaltResult =
            await cobalt.extractMediaUrl(_linkController.text.trim());

        if (!cobaltResult.success) {
          throw Exception(cobaltResult.error ?? 'Failed to extract media URL');
        }

        setState(() => _statusMessage = 'Uploading to cloud...');

        // Cloudinary: upload from raw URL
        final cloudinary = ref.read(cloudinaryServiceProvider);
        final cloudinaryUrl = await cloudinary.uploadFromUrl(
          cobaltResult.url!,
          _selectedType == ContentType.image ? 'image' : 'video',
        );

        if (cloudinaryUrl == null) {
          throw Exception('Failed to upload to cloud storage');
        }

        content = cloudinaryUrl;
      }

      setState(() => _statusMessage = 'Saving...');

      // Create feed item
      final item = FeedItem(
        id: const Uuid().v4(),
        userId: user.id,
        type: _selectedType,
        content: content,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: DateTime.now(),
        sourceUrl: _selectedType != ContentType.text
            ? _linkController.text.trim()
            : null,
      );

      // Save: online → Supabase. Offline → local
      final connected = await isConnected();
      if (connected) {
        final feedService = ref.read(feedServiceProvider);
        await feedService.createFeedItem(item);
      } else {
        final cache = ref.read(localCacheServiceProvider);
        await cache.saveItemLocally(item);
      }

      // Refresh feed
      ref.invalidate(feedItemsProvider);

      setState(() {
        _statusMessage = 'Added to your feed!';
        _isError = false;
      });

      // Clear fields
      _linkController.clear();
      _textController.clear();
      _noteController.clear();

      // Clear status after 2s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _statusMessage = null);
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().replaceAll('Exception: ', '');
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Jet',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'Add content to your feed',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: theme.textTheme.bodySmall?.color,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),

              // Content type selector
              Text(
                'Content type',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ContentType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final label = type.name[0].toUpperCase() + type.name.substring(1);
                  final icon = type == ContentType.text
                      ? Icons.article_rounded
                      : type == ContentType.image
                          ? Icons.image_rounded
                          : Icons.videocam_rounded;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(
                          right: type != ContentType.video ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent.withValues(alpha: 0.12)
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? accent.withValues(alpha: 0.35)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(icon,
                                color: isSelected
                                    ? accent
                                    : theme.textTheme.bodySmall?.color,
                                size: 22),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? accent
                                    : theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 32),

              // Input fields based on content type
              if (_selectedType == ContentType.text) ...[
                Text(
                  'Write your content',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  maxLines: 10,
                  minLines: 5,
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write or paste markdown here...',
                    alignLabelWithHint: true,
                  ),
                ),
              ] else ...[
                Text(
                  'Paste a link',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _linkController,
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Instagram, YouTube, or any URL...',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The link will be processed through Cobalt and stored on Cloudinary.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Private note (optional)
              Text(
                'Private note (optional)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                minLines: 1,
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'A personal note for this item...',
                ),
              ),
              const SizedBox(height: 32),

              // Status message
              if (_statusMessage != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isError
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isError
                          ? theme.colorScheme.error.withValues(alpha: 0.3)
                          : accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isUploading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      else
                        Icon(
                          _isError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _isError
                              ? theme.colorScheme.error
                              : accent,
                          size: 18,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _isError
                                ? theme.colorScheme.error
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Upload button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _handleUpload,
                  icon: _isUploading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.bolt_rounded, size: 20),
                  label: Text(_isUploading ? 'Processing...' : 'Jet it'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
