import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/feed_item.dart';
import '../providers/providers.dart';
import '../widgets/content_type_chip.dart';
import '../widgets/feed_card/video_card.dart';
import '../widgets/feed_card/image_card.dart';
import '../widgets/feed_card/text_card.dart';
import '../utils/connectivity.dart';

/// The main feed screen — full-screen card scrolling, TikTok-style.
class InterceptScreen extends ConsumerStatefulWidget {
  const InterceptScreen({super.key});

  @override
  ConsumerState<InterceptScreen> createState() => _InterceptScreenState();
}

class _InterceptScreenState extends ConsumerState<InterceptScreen> {
  final PageController _pageController = PageController();
  final Map<int, bool> _noteVisibility = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  double _lastPage = 0;

  void _onScroll() {
    final currentPage = _pageController.page ?? 0;
    final isScrollingDown = currentPage > _lastPage;
    _lastPage = currentPage;

    final isVisible = ref.read(navBarVisibleProvider);
    if (isScrollingDown && isVisible) {
      ref.read(navBarVisibleProvider.notifier).state = false;
    } else if (!isScrollingDown && !isVisible) {
      ref.read(navBarVisibleProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedItemsProvider);
    final filter = ref.watch(feedFilterProvider);
    final isOnline = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Feed content
        feedAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState(theme, isOnline.value ?? true);
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: items.length,
              onPageChanged: (index) {
                // Show nav bar when user reaches a new page
                ref.read(navBarVisibleProvider.notifier).state = true;
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final showNote = _noteVisibility[index] ?? false;

                return _buildCard(item, index, showNote);
              },
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(feedItemsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content type filter chips — top of screen
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ContentTypeChip(
                    label: 'All',
                    icon: Icons.dashboard_rounded,
                    isSelected: filter == FeedFilter.all,
                    onTap: () {
                      ref.read(feedFilterProvider.notifier).state =
                          FeedFilter.all;
                      ref.invalidate(feedItemsProvider);
                    },
                  ),
                  const SizedBox(width: 4),
                  ContentTypeChip(
                    label: 'Text',
                    icon: Icons.article_rounded,
                    isSelected: filter == FeedFilter.text,
                    onTap: () {
                      ref.read(feedFilterProvider.notifier).state =
                          FeedFilter.text;
                      ref.invalidate(feedItemsProvider);
                    },
                  ),
                  const SizedBox(width: 4),
                  ContentTypeChip(
                    label: 'Image',
                    icon: Icons.image_rounded,
                    isSelected: filter == FeedFilter.image,
                    onTap: () {
                      ref.read(feedFilterProvider.notifier).state =
                          FeedFilter.image;
                      ref.invalidate(feedItemsProvider);
                    },
                  ),
                  const SizedBox(width: 4),
                  ContentTypeChip(
                    label: 'Video',
                    icon: Icons.videocam_rounded,
                    isSelected: filter == FeedFilter.video,
                    onTap: () {
                      ref.read(feedFilterProvider.notifier).state =
                          FeedFilter.video;
                      ref.invalidate(feedItemsProvider);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0),
          ),
        ),

        // Offline indicator
        if (isOnline.value == false)
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Offline — showing text content only',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(FeedItem item, int index, bool showNote) {
    switch (item.type) {
      case ContentType.video:
        return VideoCard(
          item: item,
          showNote: showNote,
          onNoteToggle: () => _toggleNote(index),
        );
      case ContentType.image:
        return ImageCard(
          item: item,
          showNote: showNote,
          onNoteToggle: () => _toggleNote(index),
        );
      case ContentType.text:
        return TextCard(
          item: item,
          showNote: showNote,
          onNoteToggle: () => _toggleNote(index),
        );
    }
  }

  void _toggleNote(int index) {
    setState(() {
      _noteVisibility[index] = !(_noteVisibility[index] ?? false);
    });
  }

  Widget _buildEmptyState(ThemeData theme, bool isOnline) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.space_dashboard_outlined,
              size: 64,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Your feed is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOnline
                  ? 'Head to Jet to add your first content'
                  : 'Connect to the internet to see your content',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.95, 0.95), duration: 600.ms),
      ),
    );
  }
}
