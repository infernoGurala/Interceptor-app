import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';
import '../utils/markdown_utils.dart';
import 'revise_screen.dart';

/// Minimal Hub / Home screen.
class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final feedAsync = ref.watch(feedItemsProvider);
    final folderState = ref.watch(selectedFolderProvider);
    final notesEnabled = ref.watch(customFeedNotesProvider);

    final noteCount = feedAsync.value?.length ?? 0;
    final folderPath = folderState.value;
    final folderName = folderPath != null
        ? p.basename(folderPath)
        : 'Local Storage';
    final topItem = feedAsync.value?.isNotEmpty == true
        ? feedAsync.value!.first
        : null;

    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
          children: [
            // Header
            Text(
              'Home',
              style: GoogleFonts.inter(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              folderName,
              style: GoogleFonts.inter(fontSize: 14, color: muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),

            // Primary: Revise
            _ReviseCard(
              noteCount: noteCount,
              notesEnabled: notesEnabled,
              snippet: topItem?.content,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReviseScreen()),
              ),
            ),
          ]
              .animate(interval: 40.ms)
              .fadeIn(duration: 300.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }
}

/// Shared flat surface decoration.
BoxDecoration _surface(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.025),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05),
    ),
  );
}

/// The primary card: opens the custom Revise feed settings.
class _ReviseCard extends StatelessWidget {
  final int noteCount;
  final bool notesEnabled;
  final String? snippet;
  final VoidCallback onTap;

  const _ReviseCard({
    required this.noteCount,
    required this.notesEnabled,
    required this.snippet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final body = theme.textTheme.bodyMedium?.color;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    final cleaned = snippet == null
        ? null
        : cleanForDisplay(snippet!)
            .replaceAll(RegExp(r'[#*`>\-]'), '')
            .replaceAll('==', '')
            .trim();
    final hasSnippet = cleaned != null && cleaned.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: _surface(theme),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 20,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revise',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notesEnabled
                              ? 'Notes active • $noteCount notes'
                              : 'Custom feed paused',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                ],
              ),
              if (hasSnippet && notesEnabled) ...[
                const SizedBox(height: 16),
                Text(
                  cleaned,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: body?.withValues(alpha: 0.85),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
