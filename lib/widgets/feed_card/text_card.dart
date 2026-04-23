import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/feed_item.dart';
import 'mermaid_block.dart';

/// A full-screen text/markdown card for the feed.
/// Renders markdown with LaTeX (both $ and $$) and Mermaid chart support.
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

  /// Parses content into segments: either plain markdown or mermaid blocks.
  List<_ContentSegment> _parseContent(String content) {
    final segments = <_ContentSegment>[];
    final mermaidPattern = RegExp(
      r'```mermaid\s*\n([\s\S]*?)```',
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in mermaidPattern.allMatches(content)) {
      // Add any markdown before this mermaid block
      if (match.start > lastEnd) {
        final mdText = content.substring(lastEnd, match.start).trim();
        if (mdText.isNotEmpty) {
          segments.add(_ContentSegment(type: _SegmentType.markdown, content: mdText));
        }
      }
      // Add the mermaid block
      segments.add(_ContentSegment(
        type: _SegmentType.mermaid,
        content: match.group(1)!.trim(),
      ));
      lastEnd = match.end;
    }

    // Add any remaining markdown after the last mermaid block
    if (lastEnd < content.length) {
      final mdText = content.substring(lastEnd).trim();
      if (mdText.isNotEmpty) {
        segments.add(_ContentSegment(type: _SegmentType.markdown, content: mdText));
      }
    }

    // If no mermaid blocks found, return the whole content as markdown
    if (segments.isEmpty) {
      segments.add(_ContentSegment(type: _SegmentType.markdown, content: content));
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final segments = _parseContent(item.content);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Content with internal scroll
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 56,
                left: 24,
                right: 24,
                bottom: 120,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: segments.map((segment) {
                              if (segment.type == _SegmentType.mermaid) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: MermaidBlock(
                                    code: segment.content,
                                    isDark: isDark,
                                  ),
                                );
                              }

                              // Markdown + LaTeX segment
                              return SelectionArea(
                                child: GptMarkdown(
                                  segment.content,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textTheme.bodyLarge?.color,
                                    height: 1.7,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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

enum _SegmentType { markdown, mermaid }

class _ContentSegment {
  final _SegmentType type;
  final String content;

  const _ContentSegment({required this.type, required this.content});
}
