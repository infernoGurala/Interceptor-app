import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import '../../models/feed_item.dart';
import '../../themes/theme_provider.dart';
import '../../utils/markdown_utils.dart';
import 'highlight_syntax.dart';

/// A full-page markdown card for the feed.
/// Clean reading layout; the private note (if any) sits quietly at the end.
class TextCard extends ConsumerStatefulWidget {
  final FeedItem item;

  const TextCard({super.key, required this.item});

  @override
  ConsumerState<TextCard> createState() => TextCardState();
}

class TextCardState extends ConsumerState<TextCard> {
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  bool _showNote = false;

  /// Captures a screenshot of the note auto-cropped to the content's exact bounding box.
  Future<Uint8List?> captureScreenshot() async {
    try {
      final themeBg = Theme.of(context).scaffoldBackgroundColor;
      final boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      const pixelRatio = 3.0;
      final ui.Image fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      final contentBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (contentBox == null) {
        final byteData =
            await fullImage.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }

      // Calculate position of content relative to boundary
      final contentOffset =
          contentBox.localToGlobal(Offset.zero, ancestor: boundary);
      final contentSize = contentBox.size;

      // Add comfortable padding around the content (20 logical px)
      const paddingLogical = 20.0;
      final leftLogical = math.max(0.0, contentOffset.dx - paddingLogical);
      final topLogical = math.max(0.0, contentOffset.dy - paddingLogical);
      final widthLogical = contentSize.width + (paddingLogical * 2);
      final heightLogical = contentSize.height + (paddingLogical * 2);

      final cropLeft =
          (leftLogical * pixelRatio).clamp(0.0, fullImage.width.toDouble());
      final cropTop =
          (topLogical * pixelRatio).clamp(0.0, fullImage.height.toDouble());
      final cropWidth = (widthLogical * pixelRatio)
          .clamp(1.0, fullImage.width.toDouble() - cropLeft);
      final cropHeight = (heightLogical * pixelRatio)
          .clamp(1.0, fullImage.height.toDouble() - cropTop);

      final srcRect = Rect.fromLTWH(cropLeft, cropTop, cropWidth, cropHeight);
      final dstRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Solid background matching theme
      canvas.drawRect(dstRect, Paint()..color = themeBg);

      // Draw the cropped note content
      canvas.drawImageRect(
        fullImage,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final croppedImage =
          await picture.toImage(cropWidth.toInt(), cropHeight.toInt());
      final byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing note screenshot: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontPair = ref.watch(themeProvider).fontPair;
    final isDark = theme.brightness == Brightness.dark;
    final text = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);
    final subtle = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    final note = widget.item.note;
    final hasNote = note != null && note.isNotEmpty;
    final title = p.basenameWithoutExtension(
      widget.item.sourceUrl ?? widget.item.id,
    );
    final topInset = math.max(
      MediaQuery.viewPaddingOf(context).top,
      MediaQuery.paddingOf(context).top,
    );
    final topPadding = topInset + 66;

    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
            // Clamping (not bouncing) so hitting the top/bottom emits
            // OverscrollNotification, which the feed uses to change page.
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, topPadding, 24, 140),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  key: _contentKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // File name
                Text(
                  title,
                  style: fontPair.headStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.25,
                    color: text,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, thickness: 1, color: subtle),
                const SizedBox(height: 18),
                MarkdownBody(
                  data: cleanForDisplay(widget.item.content),
                  selectable: true,
                  extensionSet: md.ExtensionSet(
                    md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                    [
                      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                      HighlightSyntax(),
                    ],
                  ),
                  builders: {
                    'mark': HighlightBuilder(theme),
                  },
                  styleSheet: MarkdownStyleSheet(
                    h1: fontPair.headStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.25,
                      color: text,
                    ),
                    h2: fontPair.headStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: text,
                    ),
                    h3: fontPair.headStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: text,
                    ),
                    h4: fontPair.headStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: text,
                    ),
                    h1Padding: const EdgeInsets.only(bottom: 8),
                    h2Padding: const EdgeInsets.only(top: 12, bottom: 4),
                    h3Padding: const EdgeInsets.only(top: 8, bottom: 2),
                    p: fontPair.bodyStyle(
                      fontSize: 17,
                      height: 1.65,
                      color: text,
                    ),
                    pPadding: const EdgeInsets.only(bottom: 4),
                    blockSpacing: 14,
                    em: fontPair.bodyStyle(
                      fontStyle: FontStyle.italic,
                      color: text,
                    ),
                    strong: fontPair.bodyStyle(
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                    listBullet: fontPair.bodyStyle(
                      fontSize: 17,
                      height: 1.65,
                      color: muted,
                    ),
                    code: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: text,
                      backgroundColor: subtle,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: subtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    codeblockPadding: const EdgeInsets.all(14),
                    blockquote: fontPair.bodyStyle(
                      fontSize: 17,
                      height: 1.65,
                      color: muted,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: muted ?? Colors.grey, width: 2),
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.fromLTRB(14, 2, 0, 2),
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(top: BorderSide(color: subtle, width: 1)),
                    ),
                    a: fontPair.bodyStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: theme.colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),

                // Private note — tucked at the end of the content.
                if (hasNote) ...[
                  const SizedBox(height: 32),
                  InkWell(
                    onTap: () => setState(() => _showNote = !_showNote),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: muted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showNote ? 'Hide note' : 'Show note',
                            style: fontPair.bodyStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topLeft,
                    child: _showNote
                        ? Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: subtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              note,
                              style: fontPair.bodyStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}
