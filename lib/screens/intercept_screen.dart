import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/feed_item.dart';
import '../providers/providers.dart';
import '../widgets/feed_card/image_card.dart';
import '../widgets/feed_card/text_card.dart';
import '../widgets/feed_card/video_card.dart';
import '../widgets/note_editor_sheet.dart';

/// The main feed screen — full-screen Markdown pages, swipe vertically.
class InterceptScreen extends ConsumerStatefulWidget {
  const InterceptScreen({super.key});

  @override
  ConsumerState<InterceptScreen> createState() => _InterceptScreenState();
}

class _InterceptScreenState extends ConsumerState<InterceptScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final GlobalKey<TextCardState> _currentTextCardKey = GlobalKey<TextCardState>();
  int _page = 0;
  bool _isSharing = false;

  // Hand-off from a long note's inner scroll to the feed.
  static const _pageThreshold = 60.0;
  double _overscroll = 0;
  bool _paging = false;

  Timer? _autoOffTimer;

  void _applySystemUI(bool visible) {
    if (visible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _startAutoOffTimer() {
    _autoOffTimer?.cancel();
    _autoOffTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _setChromeVisible(false);
      }
    });
  }

  void _cancelAutoOffTimer() {
    _autoOffTimer?.cancel();
    _autoOffTimer = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Show chrome on initial mount, with auto-off
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navBarVisibleProvider.notifier).state = true;
        _applySystemUI(true);
        _startAutoOffTimer();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final isChromeVisible = ref.read(navBarVisibleProvider);
      _applySystemUI(isChromeVisible);
    }
  }

  @override
  void deactivate() {
    _applySystemUI(true);
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoOffTimer?.cancel();
    _pageController.dispose();
    _applySystemUI(true);
    super.dispose();
  }

  void _setChromeVisible(bool visible) {
    if (ref.read(navBarVisibleProvider) != visible) {
      ref.read(navBarVisibleProvider.notifier).state = visible;
    }
    _applySystemUI(visible);
  }

  void _toggleChrome() {
    final current = ref.read(navBarVisibleProvider);
    if (current) {
      // User tapped while showing -> turn off immediately
      _cancelAutoOffTimer();
      _setChromeVisible(false);
    } else {
      // User soft-clicked while hidden -> turn on, and start auto-off timer
      _setChromeVisible(true);
      _startAutoOffTimer();
    }
  }

  // Pointer event tracking for manual soft-click toggle without conflicting with scrolling or long-press
  Offset? _pointerDownPos;
  int _pointerDownTime = 0;
  bool _pointerMoved = false;

  void _onPointerDown(PointerDownEvent e) {
    _pointerDownPos = e.position;
    _pointerDownTime = DateTime.now().millisecondsSinceEpoch;
    _pointerMoved = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointerDownPos != null) {
      final dist = (e.position - _pointerDownPos!).distance;
      if (dist > 12.0) {
        _pointerMoved = true;
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_pointerDownPos != null && !_pointerMoved) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - _pointerDownTime;
      final dist = (e.position - _pointerDownPos!).distance;
      // Soft click: brief duration and minimal movement
      if (elapsed < 350 && dist <= 12.0) {
        _toggleChrome();
      }
    }
    _pointerDownPos = null;
    _pointerMoved = false;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pointerDownPos = null;
    _pointerMoved = false;
  }

  /// Handles overscroll hand-off to flip previous/next note.
  bool _handleScrollNotification(ScrollNotification n) {
    if (n is OverscrollNotification && n.dragDetails != null && !_paging) {
      _overscroll += n.overscroll;
      if (_overscroll.abs() >= _pageThreshold) {
        final forward = _overscroll > 0;
        _overscroll = 0;
        _paging = true;
        final anim = forward
            ? _pageController.nextPage(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              )
            : _pageController.previousPage(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              );
        anim.whenComplete(() => _paging = false);
      }
    } else if (n is ScrollStartNotification || n is ScrollEndNotification) {
      _overscroll = 0;
    }

    return false;
  }

  Future<void> _pickFolder() async {
    final dir = await FilePickerPlatform.instance.getDirectoryPath();
    if (dir != null) {
      await ref.read(selectedFolderProvider.notifier).setFolderPath(dir);
      ref.invalidate(feedItemsProvider);
      setState(() => _page = 0);
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _editCurrentNote(FeedItem item) {
    _cancelAutoOffTimer();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NoteEditorSheet(
        item: item,
        onSaved: () {
          ref.invalidate(feedItemsProvider);
        },
      ),
    );
  }

  Future<void> _shareCurrentItem(FeedItem item) async {
    _cancelAutoOffTimer();
    setState(() => _isSharing = true);
    try {
      final title = p.basenameWithoutExtension(item.sourceUrl ?? item.id);

      if (item.type == ContentType.image) {
        final file = File(item.content);
        if (await file.exists()) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(item.content)],
              text: title,
              title: title,
            ),
          );
        } else {
          _showToast('Image file not found');
        }
      } else if (item.type == ContentType.video) {
        final file = File(item.content);
        if (await file.exists()) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(item.content)],
              text: title,
              title: title,
            ),
          );
        } else {
          _showToast('Video file not found');
        }
      } else {
        // Text/Markdown note: Capture auto-cropped screenshot
        final bytes =
            await _currentTextCardKey.currentState?.captureScreenshot();
        if (bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final filename = 'note_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${tempDir.path}/$filename');
          await file.writeAsBytes(bytes);

          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path, mimeType: 'image/png')],
              text: title,
              title: title,
            ),
          );
        } else {
          _showToast('Could not capture note screenshot');
        }
      }
    } catch (e) {
      _showToast('Failed to share: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChromeVisible = ref.watch(navBarVisibleProvider);
    final feedAsync = ref.watch(feedItemsProvider);
    final folderPath = ref.watch(selectedFolderProvider).value;
    final items = feedAsync.value ?? [];
    final total = items.length;
    final currentItem =
        items.isNotEmpty && _page < items.length ? items[_page] : null;
    final canEdit = currentItem != null && currentItem.type == ContentType.text;

    final topInset = math.max(
      MediaQuery.viewPaddingOf(context).top,
      MediaQuery.paddingOf(context).top,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Content with tap-to-toggle and scroll-direction handlers
          Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: feedAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _Message(
                      title: 'No notes yet',
                      body: folderPath == null
                          ? 'Choose a folder with .md files.'
                          : 'This folder has no .md files.',
                      primary: ('Choose folder', _pickFolder),
                    );
                  }
                  return PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      switch (item.type) {
                        case ContentType.image:
                          return ImageCard(item: item);
                        case ContentType.video:
                          return VideoCard(item: item);
                        case ContentType.audio:
                        case ContentType.text:
                          return TextCard(
                            key: i == _page
                                ? _currentTextCardKey
                                : ValueKey(item.id),
                            item: item,
                          );
                      }
                    },
                  );
                },
                loading: () => Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                error: (error, _) => _Message(
                  title: 'Couldn\'t read folder',
                  body: error.toString(),
                  primary: ('Choose another folder', _pickFolder),
                ),
              ),
            ),
          ),

          // Top bar overlay (auto-hides with navbar, shows back on pull down)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !isChromeVisible,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                offset: isChromeVisible ? Offset.zero : const Offset(0, -1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isChromeVisible ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.75, 1.0],
                      ),
                    ),
                    padding: EdgeInsets.only(top: topInset + 6, bottom: 14),
                    child: _TopBar(
                      position: total > 0 ? '${_page + 1} / $total' : null,
                      onRefresh: () => ref.invalidate(feedItemsProvider),
                      canEdit: canEdit,
                      isSharing: _isSharing,
                      onEdit: currentItem != null
                          ? () => _editCurrentNote(currentItem)
                          : null,
                      onShare: currentItem != null
                          ? () => _shareCurrentItem(currentItem)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain top bar overlay:
/// - Left: static 'Feed' title (styled like Home/Write/Settings)
/// - Right: Edit Note button, Share Screenshot button, position indicator + refresh button.
class _TopBar extends StatelessWidget {
  final String? position;
  final VoidCallback onRefresh;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final bool canEdit;
  final bool isSharing;

  const _TopBar({
    required this.position,
    required this.onRefresh,
    this.onEdit,
    this.onShare,
    this.canEdit = true,
    this.isSharing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Feed',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: text,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Edit note directly in-feed
              IconButton(
                onPressed: canEdit ? onEdit : null,
                tooltip: canEdit ? 'Edit note' : 'Only text notes can be edited',
                icon: Icon(
                  Icons.edit_note_rounded,
                  size: 24,
                  color: canEdit ? text : muted?.withValues(alpha: 0.3),
                ),
              ),
              // 2. Share screenshot (auto cropped for best fit)
              IconButton(
                onPressed: isSharing ? null : onShare,
                tooltip: 'Share screenshot',
                icon: isSharing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.ios_share_rounded,
                        size: 20,
                        color: text,
                      ),
              ),
              if (position != null) ...[
                const SizedBox(width: 4),
                Text(
                  position!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: muted,
                  ),
                ),
                const SizedBox(width: 2),
              ],
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Rescan',
                icon: Icon(Icons.refresh_rounded, size: 20, color: muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple centered message for empty / error states.
class _Message extends StatelessWidget {
  final String title;
  final String body;
  final (String, VoidCallback) primary;

  const _Message({
    required this.title,
    required this.body,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: muted),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: primary.$2, child: Text(primary.$1)),
          ],
        ),
      ),
    );
  }
}
