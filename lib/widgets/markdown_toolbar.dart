import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An Obsidian-style markdown formatting toolbar that sits above the keyboard.
/// Provides bold, italic, strikethrough, heading, code, link, list,
/// quote, undo, and redo actions.
class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool canUndo;
  final bool canRedo;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.onUndo,
    this.onRedo,
    this.canUndo = false,
    this.canRedo = false,
  });

  void _wrapSelection(String before, String after) {
    final text = controller.text;
    final sel = controller.selection;

    if (!sel.isValid) return;

    final selectedText = sel.textInside(text);

    String newText;
    int newStart;
    int newEnd;

    if (selectedText.isNotEmpty) {
      newText = text.replaceRange(sel.start, sel.end, '$before$selectedText$after');
      newStart = sel.start + before.length;
      newEnd = newStart + selectedText.length;
    } else {
      newText = text.replaceRange(sel.start, sel.end, '$before$after');
      newStart = sel.start + before.length;
      newEnd = newStart;
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
    );
  }

  void _insertAtLineStart(String prefix) {
    final text = controller.text;
    final sel = controller.selection;

    if (!sel.isValid) return;

    int lineStart = sel.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    final newOffset = sel.start + prefix.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _insertLink() {
    final text = controller.text;
    final sel = controller.selection;

    if (!sel.isValid) return;

    final selectedText = sel.textInside(text);

    if (selectedText.isNotEmpty) {
      final newText = text.replaceRange(sel.start, sel.end, '[$selectedText](url)');
      final urlStart = sel.start + selectedText.length + 3;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(baseOffset: urlStart, extentOffset: urlStart + 3),
      );
    } else {
      final newText = text.replaceRange(sel.start, sel.end, '[text](url)');
      final textStart = sel.start + 1;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(baseOffset: textStart, extentOffset: textStart + 4),
      );
    }
  }

  void _insertLatexInline() {
    _wrapSelection(r'$', r'$');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F2F2),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          // Undo / Redo
          _ToolbarIconButton(
            icon: Icons.undo_rounded,
            onTap: canUndo ? onUndo : null,
            isDark: isDark,
          ),
          _ToolbarIconButton(
            icon: Icons.redo_rounded,
            onTap: canRedo ? onRedo : null,
            isDark: isDark,
          ),
          _divider(isDark),

          // Formatting
          _ToolbarIconButton(
            icon: Icons.format_bold_rounded,
            onTap: () => _wrapSelection('**', '**'),
            isDark: isDark,
          ),
          _ToolbarIconButton(
            icon: Icons.format_italic_rounded,
            onTap: () => _wrapSelection('*', '*'),
            isDark: isDark,
          ),
          _ToolbarIconButton(
            icon: Icons.strikethrough_s_rounded,
            onTap: () => _wrapSelection('~~', '~~'),
            isDark: isDark,
          ),
          _divider(isDark),

          // Heading
          _ToolbarTextButton(
            text: 'H',
            onTap: () => _insertAtLineStart('## '),
            isDark: isDark,
          ),
          // Code inline
          _ToolbarIconButton(
            icon: Icons.code_rounded,
            onTap: () => _wrapSelection('`', '`'),
            isDark: isDark,
          ),
          // Link
          _ToolbarIconButton(
            icon: Icons.link_rounded,
            onTap: _insertLink,
            isDark: isDark,
          ),
          _divider(isDark),

          // Bullet list
          _ToolbarIconButton(
            icon: Icons.format_list_bulleted_rounded,
            onTap: () => _insertAtLineStart('- '),
            isDark: isDark,
          ),
          // Quote
          _ToolbarIconButton(
            icon: Icons.format_quote_rounded,
            onTap: () => _insertAtLineStart('> '),
            isDark: isDark,
          ),
          // LaTeX inline
          _ToolbarTextButton(
            text: '∑',
            onTap: _insertLatexInline,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Center(
      child: Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _ToolbarIconButton({
    required this.icon,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 44,
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: isDisabled
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.15))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isDark;

  const _ToolbarTextButton({
    required this.text,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 44,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
