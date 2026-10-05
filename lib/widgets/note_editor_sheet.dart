import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import '../models/feed_item.dart';
import '../providers/providers.dart';
import '../themes/theme_provider.dart';
import '../utils/markdown_utils.dart';
import 'feed_card/highlight_syntax.dart';

/// Full-height in-feed modal editor for notes.
/// Allows editing title and Markdown content directly with live preview and quick formatting.
class NoteEditorSheet extends ConsumerStatefulWidget {
  final FeedItem item;
  final VoidCallback onSaved;

  const NoteEditorSheet({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends ConsumerState<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final FocusNode _bodyFocusNode;

  bool _isPreview = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final (initialTitle, initialBody) = _extractTitleAndBody(widget.item);
    _titleController = TextEditingController(text: initialTitle);
    _bodyController = TextEditingController(text: initialBody);
    _bodyFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  (String, String) _extractTitleAndBody(FeedItem item) {
    final raw = item.content.trim();
    final lines = raw.split('\n');
    if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
      final title = lines.first.trim().substring(2).trim();
      final body = lines.sublist(1).join('\n').trim();
      return (title, body);
    }
    final title = p.basenameWithoutExtension(item.sourceUrl ?? item.id);
    return (title, raw);
  }

  String _assembleMarkdown() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) return body;

    final lines = body.split('\n');
    if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
      lines[0] = '# $title';
      return lines.join('\n');
    }
    return '# $title\n\n$body';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updatedContent = _assembleMarkdown();
      final filePath = widget.item.id;
      final file = File(filePath);

      if (await file.exists()) {
        await file.writeAsString(updatedContent);
      } else {
        // Fallback: create through folder service
        final folderService = ref.read(localFolderServiceProvider);
        final folderPath = ref.read(selectedFolderProvider).value;
        await folderService.createMarkdownNote(
          title: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : 'Untitled Note',
          content: _bodyController.text.trim(),
          folderPath: folderPath,
        );
      }

      ref.invalidate(feedItemsProvider);
      widget.onSaved();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Note updated successfully',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save note: $e',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _insertMarkdown(String prefix, [String suffix = '']) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final selectedText = text.substring(start, end);

    final replacement = '$prefix$selectedText$suffix';
    final newText = text.replaceRange(start, end, replacement);

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selectedText.length + (selectedText.isEmpty ? 0 : suffix.length),
      ),
    );
    _bodyFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontPair = ref.watch(themeProvider).fontPair;
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);
    final subtleBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final fileName = p.basename(widget.item.sourceUrl ?? widget.item.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: muted?.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, size: 22, color: text),
                  tooltip: 'Cancel',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Note',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: text,
                        ),
                      ),
                      Text(
                        fileName,
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Preview Toggle Button
                IconButton(
                  onPressed: () => setState(() => _isPreview = !_isPreview),
                  tooltip: _isPreview ? 'Edit mode' : 'Preview mode',
                  icon: Icon(
                    _isPreview
                        ? Icons.edit_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: _isPreview ? primary : muted,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isPreview
                        ? primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 8),
                // Save Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: subtleBorder),

          // Main Editor / Preview Body
          Expanded(
            child: _isPreview
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_titleController.text.trim().isNotEmpty) ...[
                              Text(
                                _titleController.text.trim(),
                                style: fontPair.headStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: text,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Divider(height: 1, thickness: 1, color: subtleBorder),
                              const SizedBox(height: 18),
                            ],
                            MarkdownBody(
                              data: cleanForDisplay(_bodyController.text),
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
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: text,
                                ),
                                h2: fontPair.headStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: text,
                                ),
                                p: fontPair.bodyStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    children: [
                      // Note Title Field
                      TextField(
                        controller: _titleController,
                        style: fontPair.headStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Note title...',
                          hintStyle: fontPair.headStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: muted?.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 1, color: subtleBorder),
                      const SizedBox(height: 16),

                      // Markdown Body Field
                      TextField(
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        maxLines: null,
                        minLines: 14,
                        keyboardType: TextInputType.multiline,
                        style: fontPair.bodyStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing markdown...',
                          hintStyle: fontPair.bodyStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: muted?.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
          ),

          // Markdown Quick Toolbar (Only in edit mode)
          if (!_isPreview)
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.black.withValues(alpha: 0.025),
                border: Border(top: BorderSide(color: subtleBorder)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildToolButton('H1', () => _insertMarkdown('# ')),
                    _buildToolButton('H2', () => _insertMarkdown('## ')),
                    _buildToolButton('B', () => _insertMarkdown('**', '**'), isBold: true),
                    _buildToolButton('I', () => _insertMarkdown('*', '*'), isItalic: true),
                    _buildToolButton('==', () => _insertMarkdown('==', '==')),
                    _buildToolButton('List', () => _insertMarkdown('- ')),
                    _buildToolButton('Quote', () => _insertMarkdown('> ')),
                    _buildToolButton('Code', () => _insertMarkdown('`', '`')),
                    _buildToolButton('Task', () => _insertMarkdown('- [ ] ')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    String label,
    VoidCallback onTap, {
    bool isBold = false,
    bool isItalic = false,
  }) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}
