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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  // ───── Content type filter for the content section ─────
  ContentType? _typeFilter;

  Widget _buildContentGrid(ThemeData theme) {
    final feedAsync = ref.watch(feedItemsProvider);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _typeFilter == null,
                accent: accent,
                isDark: isDark,
                onTap: () => setState(() => _typeFilter = null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Text',
                icon: Icons.article_rounded,
                isSelected: _typeFilter == ContentType.text,
                accent: accent,
                isDark: isDark,
                onTap: () => setState(() => _typeFilter =
                    _typeFilter == ContentType.text ? null : ContentType.text),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Image',
                icon: Icons.image_rounded,
                isSelected: _typeFilter == ContentType.image,
                accent: accent,
                isDark: isDark,
                onTap: () => setState(() => _typeFilter =
                    _typeFilter == ContentType.image ? null : ContentType.image),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Video',
                icon: Icons.videocam_rounded,
                isSelected: _typeFilter == ContentType.video,
                accent: accent,
                isDark: isDark,
                onTap: () => setState(() => _typeFilter =
                    _typeFilter == ContentType.video ? null : ContentType.video),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Search bar ──
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'Search content, notes, or URLs...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: AnimatedRotation(
                        turns: _searchQuery.isNotEmpty ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.close_rounded,
                          color: theme.textTheme.bodySmall?.color,
                          size: 18,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Content list ──
        feedAsync.when(
          data: (items) {
            // Apply type filter
            var filtered = _typeFilter == null
                ? items
                : items.where((item) => item.type == _typeFilter).toList();

            // Apply search filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              filtered = filtered.where((item) {
                final contentMatch =
                    item.content.toLowerCase().contains(query);
                final noteMatch =
                    item.note?.toLowerCase().contains(query) ?? false;
                final sourceMatch =
                    item.sourceUrl?.toLowerCase().contains(query) ?? false;
                final typeMatch =
                    item.type.name.toLowerCase().contains(query);
                return contentMatch || noteMatch || sourceMatch || typeMatch;
              }).toList();
            }

            if (items.isEmpty) {
              return _buildEmptyContent(theme, isDark);
            }

            if (filtered.isEmpty) {
              return _buildNoResults(theme, isDark);
            }

            // Show count
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Result count
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                // Content list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildContentTile(item, theme, isDark, accent);
                  },
                ),
              ],
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
              child: Column(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: theme.colorScheme.error, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load content',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(feedItemsProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Color accent,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.15)
              : isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? accent
                    : isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? accent
                    : isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No content yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Head to Jet to add your first item',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 36,
              color:
                  theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No ${_typeFilter?.name ?? ''} content found',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            if (_searchQuery.isNotEmpty || _typeFilter != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _typeFilter = null;
                  });
                },
                child: Text(
                  'Clear filters',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentTile(
    FeedItem item,
    ThemeData theme,
    bool isDark,
    Color accent,
  ) {
    final preview = _getPreviewText(item);
    final icon = _getTypeIcon(item.type);
    final typeColor = _getTypeColor(item.type, accent, theme);

    return GestureDetector(
      onTap: () => _showEditSheet(item),
      onLongPress: () => _showDeleteDialog(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: typeColor, size: 18),
            ),
            const SizedBox(width: 12),

            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge + timestamp
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.type.name[0].toUpperCase() +
                              item.type.name.substring(1),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(item.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.4),
                        ),
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 12,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.3),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Content preview
                  Text(
                    preview,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: theme.textTheme.bodyLarge?.color,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Note preview (if exists)
                  if (item.note != null && item.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showEditSheet(item),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showDeleteDialog(item),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPreviewText(FeedItem item) {
    switch (item.type) {
      case ContentType.text:
        return item.content.length > 120
            ? item.content.substring(0, 120)
            : item.content;
      case ContentType.image:
        return item.sourceUrl ?? item.content;
      case ContentType.video:
        return item.sourceUrl ?? item.content;
    }
  }

  Color _getTypeColor(ContentType type, Color accent, ThemeData theme) {
    switch (type) {
      case ContentType.text:
        return accent;
      case ContentType.image:
        return const Color(0xFF4FD1C5);
      case ContentType.video:
        return const Color(0xFFD4915E);
    }
  }

  void _showEditSheet(FeedItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final contentController = TextEditingController(text: item.content);
    final noteController = TextEditingController(text: item.note ?? '');
    bool isSaving = false;
    bool isDeleting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                    child: Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(item.type, accent, theme)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(item.type),
                                color:
                                    _getTypeColor(item.type, accent, theme),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.type.name[0].toUpperCase() +
                                    item.type.name.substring(1),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(
                                      item.type, accent, theme),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Edit Content',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        // Save button
                        GestureDetector(
                          onTap: isSaving
                              ? null
                              : () async {
                                  setSheetState(() => isSaving = true);
                                  await _saveEdit(
                                    item,
                                    contentController.text,
                                    noteController.text,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSaving
                                  ? accent.withValues(alpha: 0.1)
                                  : accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: isSaving
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: accent,
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),

                  // Editor body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content field
                          Text(
                            item.type == ContentType.text
                                ? 'Content'
                                : 'Media URL',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: TextField(
                              controller: contentController,
                              maxLines:
                                  item.type == ContentType.text ? 10 : 2,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                                height: 1.6,
                              ),
                              decoration: InputDecoration(
                                hintText: item.type == ContentType.text
                                    ? 'Write or edit your content...'
                                    : 'Media URL...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.4),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Note field
                          Text(
                            'Private Note',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: TextField(
                              controller: noteController,
                              maxLines: 3,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: theme.textTheme.bodyLarge?.color,
                                height: 1.6,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add a private note...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.4),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),

                          // Source URL (if media)
                          if (item.sourceUrl != null &&
                              item.sourceUrl!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Source',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : Colors.black.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.04),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    size: 14,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.sourceUrl!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: theme.textTheme.bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.5),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Meta info
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Created ${_formatDate(item.createdAt)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Delete button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isDeleting
                                  ? null
                                  : () async {
                                      setSheetState(
                                          () => isDeleting = true);
                                      Navigator.pop(context);
                                      await _deleteItem(item);
                                    },
                              icon: isDeleting
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.error,
                                      ),
                                    )
                                  : Icon(Icons.delete_outline_rounded,
                                      size: 16),
                              label: Text(
                                  isDeleting ? 'Deleting...' : 'Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error
                                      .withValues(alpha: 0.3),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.text:
        return Icons.article_rounded;
      case ContentType.image:
        return Icons.image_rounded;
      case ContentType.video:
        return Icons.videocam_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveEdit(
    FeedItem item,
    String newContent,
    String newNote,
  ) async {
    try {
      final updatedItem = item.copyWith(
        content: newContent,
        note: newNote.isEmpty ? null : newNote,
      );
      final feedService = ref.read(feedServiceProvider);
      await feedService.updateFeedItem(updatedItem);
      ref.invalidate(feedItemsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Content updated'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
