import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/feed_item.dart';

/// A full-screen text/markdown card for the feed.
/// Renders markdown with premium typography and internal scrolling.
class TextCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onNoteToggle;
  final bool showNote;

  const TextCard({
    super.key,
    required this.item,
    this.onNoteToggle,
    this.showNote = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Markdown content with internal scroll
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 56,
                left: 24,
                right: 24,
                bottom: 120,
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Markdown(
                    data: item.content,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      h1: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.3,
                      ),
                      h2: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.4,
                      ),
                      h3: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.4,
                      ),
                      h4: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.4,
                      ),
                      p: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.7,
                      ),
                      em: GoogleFonts.inter(
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      strong: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      listBullet: GoogleFonts.inter(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.7,
                      ),
                      code: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      codeblockPadding: const EdgeInsets.all(16),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                      ),
                      blockquotePadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      horizontalRuleDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      a: TextStyle(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article_rounded,
                color: theme.textTheme.bodySmall?.color,
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showNote
                            ? Icons.sticky_note_2
                            : Icons.sticky_note_2_outlined,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.note!,
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodyMedium?.color,
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
