import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';

/// The editor screen where users write Markdown notes to add to their feed.
class JetScreen extends ConsumerStatefulWidget {
  const JetScreen({super.key});

  @override
  ConsumerState<JetScreen> createState() => _JetScreenState();
}

class _JetScreenState extends ConsumerState<JetScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isPreviewMode = false;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a title or markdown content';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = 'Saving markdown note...';
      _isError = false;
    });

    try {
      final folderService = ref.read(localFolderServiceProvider);
      final folderPath = ref.read(selectedFolderProvider).value;

      final noteTitle = title.isNotEmpty ? title : 'Untitled Note';

      await folderService.createMarkdownNote(
        title: noteTitle,
        content: body,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        folderPath: folderPath,
      );

      // Refresh feed
      ref.invalidate(feedItemsProvider);

      setState(() {
        _statusMessage = 'Saved note to folder!';
        _isError = false;
      });

      // Clear fields
      _titleController.clear();
      _bodyController.clear();
      _noteController.clear();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _statusMessage = null);
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving note: $e';
        _isError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final folderPath = ref.watch(selectedFolderProvider).value;
    final folderName = folderPath != null ? p.basename(folderPath) : 'Local Folder';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write',
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
                        const SizedBox(height: 2),
                        Text(
                          'Create Markdown note in $folderName',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Edit / Preview Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _isPreviewMode = false),
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: !_isPreviewMode
                                ? accent
                                : theme.textTheme.bodySmall?.color,
                            size: 22,
                          ),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: () => setState(() => _isPreviewMode = true),
                          icon: Icon(
                            Icons.visibility_rounded,
                            color: _isPreviewMode
                                ? accent
                                : theme.textTheme.bodySmall?.color,
                            size: 20,
                          ),
                          tooltip: 'Preview',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Field
              Text(
                'Title',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Note Title...',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Body Field or Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isPreviewMode ? 'Markdown Preview' : 'Markdown Content',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (!_isPreviewMode)
                    Flexible(
                      child: Text(
                        'Supports # H1, **bold**, `code`',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (!_isPreviewMode) ...[
                TextFormField(
                  controller: _bodyController,
                  maxLines: 12,
                  minLines: 6,
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write your markdown content here...',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: MarkdownBody(
                    data: _bodyController.text.isEmpty
                        ? '*No content to preview*'
                        : '# ${_titleController.text}\n\n${_bodyController.text}',
                    styleSheet: MarkdownStyleSheet(
                      h1: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      p: GoogleFonts.inter(
                        fontSize: 15,
                        color: theme.textTheme.bodyLarge?.color,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Optional Tag / Note
              Text(
                'Private note or metadata (optional)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Personal note attached at the end...',
                ),
              ),
              const SizedBox(height: 28),

              // Status message
              if (_statusMessage != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isError
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isError
                          ? theme.colorScheme.error.withValues(alpha: 0.3)
                          : accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isSaving)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      else
                        Icon(
                          _isError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _isError
                              ? theme.colorScheme.error
                              : accent,
                          size: 18,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _isError
                                ? theme.colorScheme.error
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.note_add_rounded, size: 20),
                  label: Text(_isSaving ? 'Saving...' : 'Save Markdown Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
