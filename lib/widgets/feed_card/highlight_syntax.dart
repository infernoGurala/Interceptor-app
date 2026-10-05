import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Inline syntax to match `==highlight==` in markdown notes.
///
/// Uses strict delimiter boundaries:
/// - Must not match across newlines (prevents cross-paragraph swallowing)
/// - Disallows leading or trailing spaces inside (prevents matching `a == b` code/math comparisons)
/// - Ignores `===` setext header underlines
class HighlightSyntax extends md.InlineSyntax {
  HighlightSyntax() : super(r'==(?!\s)([^=\r\n]+?)(?<!\s)==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('mark', match[1]!));
    return true;
  }
}

/// Element builder that renders `==highlight==` as a clean boxed highlight with smooth corners.
///
/// Strictly adheres to the selected Dichrome theme palette:
/// - Uses the theme's primary accent color ([theme.colorScheme.primary]) for the highlight box.
/// - Uses the theme's background color ([theme.scaffoldBackgroundColor]) for the text inside.
/// - No extraneous third colors (no yellow/amber). Strictly follows the 2 chosen theme colors.
/// - Uses [PlaceholderAlignment.baseline] and compact height ([height: 1.15]) to prevent line collision.
class HighlightBuilder extends MarkdownElementBuilder {
  final ThemeData theme;

  HighlightBuilder(this.theme);

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // Strictly use the selected Dichrome theme's colors
    final highlightBg = theme.colorScheme.primary;
    final highlightText = theme.scaffoldBackgroundColor;

    final text = element.textContent.trim();

    // For long multi-line sentences, use native text styling so text wraps naturally without overflow
    if (text.length > 45) {
      return Text.rich(
        TextSpan(
          text: text,
          style: (parentStyle ?? preferredStyle ?? const TextStyle()).copyWith(
            backgroundColor: highlightBg,
            color: highlightText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // For terms and short phrases, render as boxed text with smooth corners
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: highlightBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: (parentStyle ?? preferredStyle ?? const TextStyle()).copyWith(
              color: highlightText,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }
}
