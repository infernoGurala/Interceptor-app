import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../themes/app_themes.dart';
import '../themes/theme_provider.dart';
import '../widgets/theme_preview_card.dart';
import '../models/feed_item.dart';

/// Profile screen — account, appearance, and content management.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _accountExpanded = false;
  bool _appearanceExpanded = false;
  bool _contentExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final user = ref.read(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profile',
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
              const SizedBox(height: 32),

              // ───── ACCOUNT SECTION ─────
              _buildSection(
                title: 'Account',
                icon: Icons.person_outline_rounded,
                isExpanded: _accountExpanded,
                onTap: () =>
                    setState(() => _accountExpanded = !_accountExpanded),
                theme: theme,
                child: Column(
                  children: [
                    // User info
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.email?.split('@').first ?? 'User',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sign out
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleSignOut,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Sign out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 12),

              // ───── APPEARANCE SECTION ─────
              _buildSection(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                isExpanded: _appearanceExpanded,
                onTap: () => setState(
                    () => _appearanceExpanded = !_appearanceExpanded),
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Light / Dark toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark mode',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Switch.adaptive(
                          value: themeState.isDark,
                          onChanged: (value) {
                            ref
                                .read(themeProvider.notifier)
                                .setDarkMode(value);
                          },
                          activeTrackColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Theme',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Theme grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: AppThemes.themeNames.length,
                      itemBuilder: (context, index) {
                        final name = AppThemes.themeNames[index];
                        return ThemePreviewCard(
                          themeName: name,
                          isDark: themeState.isDark,
                          isSelected:
                              themeState.themeName.toLowerCase() ==
                                  name.toLowerCase(),
                          onTap: () {
                            ref.read(themeProvider.notifier).setTheme(name);
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 12),

              // ───── CONTENT SECTION ─────
              _buildSection(
                title: 'Content',
                icon: Icons.grid_view_rounded,
                isExpanded: _contentExpanded,
                onTap: () =>
                    setState(() => _contentExpanded = !_contentExpanded),
                theme: theme,
                child: _buildContentGrid(theme),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.05, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required ThemeData theme,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          // Section header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon,
                      size: 20, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(ThemeData theme) {
    final feedAsync = ref.watch(feedItemsProvider);

    return feedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No content yet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildContentTile(item, theme);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Could not load content',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildContentTile(FeedItem item, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(item),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildTileContent(item, theme),
      ),
    );
  }

  Widget _buildTileContent(FeedItem item, ThemeData theme) {
    switch (item.type) {
      case ContentType.image:
        return CachedNetworkImage(
          imageUrl: item.content,
          fit: BoxFit.cover,
          placeholder: (ctx, url) => Center(
            child: Icon(Icons.image_rounded,
                color: theme.textTheme.bodySmall?.color, size: 24),
          ),
          errorWidget: (ctx, url, err) => Center(
            child: Icon(Icons.broken_image_rounded,
                color: theme.colorScheme.error, size: 24),
          ),
        );
      case ContentType.video:
        return Center(
          child: Icon(Icons.play_circle_outline_rounded,
              color: theme.textTheme.bodySmall?.color, size: 32),
        );
      case ContentType.text:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            item.content,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color,
              height: 1.3,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        );
    }
  }

  void _showDeleteDialog(FeedItem item) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete content?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteItem(item);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(FeedItem item) async {
    try {
      final feedService = ref.read(feedServiceProvider);
      await feedService.deleteFeedItem(item.id);

      final cache = ref.read(localCacheServiceProvider);
      await cache.markDeleted(item.id);

      ref.invalidate(feedItemsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Content deleted'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      final cache = ref.read(localCacheServiceProvider);

      await cache.clearAll();
      await authService.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
