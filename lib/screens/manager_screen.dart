import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';
import '../providers/vaults_provider.dart';

/// Storage Manager screen with:
/// 1st card: One vault with Custom Vaults toggle
/// 2nd card: Notes vault (greyed out when custom vaults is off)
/// 3rd card: Quotes directory
/// 4th card: Images directory
/// 5th card: Videos directory
/// 6th card: Audios directory
/// 7th section: Custom directories (can be added in infinite amount, with customizable name, location, and type: Notes, Videos, Images, Quotes, Audios, Mixed)
class ManagerScreen extends ConsumerStatefulWidget {
  const ManagerScreen({super.key});

  @override
  ConsumerState<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends ConsumerState<ManagerScreen> {
  String? _pickingTarget;

  Future<void> _pickDirectory({
    required String targetName,
    required Future<void> Function(String path) onSelected,
  }) async {
    setState(() => _pickingTarget = targetName);
    try {
      final selectedDirectory =
          await FilePickerPlatform.instance.getDirectoryPath();
      if (selectedDirectory != null && mounted) {
        await onSelected(selectedDirectory);
        ref.invalidate(feedItemsProvider);
        _showToast('$targetName location updated');
      }
    } catch (e) {
      if (mounted) _showToast('Failed to select directory: $e');
    } finally {
      if (mounted) setState(() => _pickingTarget = null);
    }
  }

  void _showAddCustomDirectoryDialog() {
    final vaults = ref.read(vaultsProvider);
    final controller = TextEditingController(
      text: 'Custom Vault ${vaults.customDirectories.length + 1}',
    );
    DirectoryType selectedType = DirectoryType.mixed;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Custom Directory',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAME',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. Study Notes, Videos, Memes...',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'CONTENT TYPE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DirectoryType.values.map((type) {
                    final isSelected = selectedType == type;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedType = type),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type.icon,
                              size: 14,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                ref.read(vaultsProvider.notifier).addCustomDirectory(
                      name: name.isNotEmpty ? name : null,
                      type: selectedType,
                    );
                ref.invalidate(feedItemsProvider);
                Navigator.of(ctx).pop();
                _showToast('Custom directory added');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameCustomDialog(String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Rename Directory',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter name...',
            hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref
                    .read(vaultsProvider.notifier)
                    .updateCustomDirectoryName(id, newName);
                ref.invalidate(feedItemsProvider);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCustomDialog(CustomDirectory dir) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Directory',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove "${dir.name}"? This only removes it from Interceptor, your local files won\'t be deleted.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(vaultsProvider.notifier).removeCustomDirectory(dir.id);
              ref.invalidate(feedItemsProvider);
              Navigator.of(ctx).pop();
              _showToast('Removed "${dir.name}"');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);
    final subtleBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.025);

    final vaults = ref.watch(vaultsProvider);
    final isCustom = vaults.isCustomVaults;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          children: [
            // Top Bar with back button
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: text,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: subtleBorder),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Configure storage vaults and directories',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ─────────────────────────────────────────────────────────────
            // 1st Card: One Vault (with Custom Vaults toggle)
            // ─────────────────────────────────────────────────────────────
            _buildOneVaultCard(
              theme: theme,
              vaults: vaults,
              isCustom: isCustom,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 20),

            // Section Label for Custom Vaults
            Row(
              children: [
                Text(
                  'CUSTOM VAULTS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isCustom)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Turn toggle on to activate',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ─────────────────────────────────────────────────────────────
            // 2nd Card: Notes Vault (location selection)
            // ─────────────────────────────────────────────────────────────
            _buildVaultCard(
              title: 'Notes Vault',
              subtitle: 'Location for Markdown notes (.md)',
              icon: Icons.article_outlined,
              path: vaults.notesVaultPath ??
                  (isCustom ? null : vaults.oneVaultPath),
              isEnabled: isCustom,
              disabledHint: 'Using One Vault location',
              isPicking: _pickingTarget == 'Notes Vault',
              onPick: () => _pickDirectory(
                targetName: 'Notes Vault',
                onSelected: (p) async {
                  await ref
                      .read(vaultsProvider.notifier)
                      .setNotesVaultPath(p);
                },
              ),
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 14),

            // ─────────────────────────────────────────────────────────────
            // 3rd Card: Quotes Directory
            // ─────────────────────────────────────────────────────────────
            _buildVaultCard(
              title: 'Quotes Directory',
              subtitle: 'Location for quotes & inspirations',
              icon: Icons.format_quote_rounded,
              path: vaults.quotesDirectoryPath,
              isEnabled: isCustom,
              disabledHint: 'Enable custom vaults to configure',
              isPicking: _pickingTarget == 'Quotes Directory',
              onPick: () => _pickDirectory(
                targetName: 'Quotes Directory',
                onSelected: (p) async {
                  await ref
                      .read(vaultsProvider.notifier)
                      .setQuotesDirectoryPath(p);
                },
              ),
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 14),

            // ─────────────────────────────────────────────────────────────
            // 4th Card: Images Directory
            // ─────────────────────────────────────────────────────────────
            _buildVaultCard(
              title: 'Images Directory',
              subtitle: 'Location for photos and images',
              icon: Icons.image_outlined,
              path: vaults.imagesDirectoryPath,
              isEnabled: isCustom,
              disabledHint: 'Enable custom vaults to configure',
              isPicking: _pickingTarget == 'Images Directory',
              onPick: () => _pickDirectory(
                targetName: 'Images Directory',
                onSelected: (p) async {
                  await ref
                      .read(vaultsProvider.notifier)
                      .setImagesDirectoryPath(p);
                },
              ),
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 14),

            // ─────────────────────────────────────────────────────────────
            // 5th Card: Videos Directory
            // ─────────────────────────────────────────────────────────────
            _buildVaultCard(
              title: 'Videos Directory',
              subtitle: 'Location for video clips and recordings',
              icon: Icons.video_library_outlined,
              path: vaults.videosDirectoryPath,
              isEnabled: isCustom,
              disabledHint: 'Enable custom vaults to configure',
              isPicking: _pickingTarget == 'Videos Directory',
              onPick: () => _pickDirectory(
                targetName: 'Videos Directory',
                onSelected: (p) async {
                  await ref
                      .read(vaultsProvider.notifier)
                      .setVideosDirectoryPath(p);
                },
              ),
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 14),

            // ─────────────────────────────────────────────────────────────
            // 6th Card: Audios Directory
            // ─────────────────────────────────────────────────────────────
            _buildVaultCard(
              title: 'Audios Directory',
              subtitle: 'Location for audio files and recordings',
              icon: Icons.headphones_outlined,
              path: vaults.audiosDirectoryPath,
              isEnabled: isCustom,
              disabledHint: 'Enable custom vaults to configure',
              isPicking: _pickingTarget == 'Audios Directory',
              onPick: () => _pickDirectory(
                targetName: 'Audios Directory',
                onSelected: (p) async {
                  await ref
                      .read(vaultsProvider.notifier)
                      .setAudiosDirectoryPath(p);
                },
              ),
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
            ),
            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────────
            // 7th Section: Custom Directories (Infinite amount with types)
            // ─────────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CUSTOM DIRECTORIES (${vaults.customDirectories.length})',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                    letterSpacing: 0.6,
                  ),
                ),
                TextButton.icon(
                  onPressed: isCustom ? _showAddCustomDirectoryDialog : null,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    'Add Directory',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    disabledForegroundColor: muted?.withValues(alpha: 0.4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (vaults.customDirectories.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: subtleBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 36, color: muted),
                      const SizedBox(height: 10),
                      Text(
                        'No custom directories added yet',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed:
                            isCustom ? _showAddCustomDirectoryDialog : null,
                        child: Text(
                          '+ Add Custom Directory',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCustom ? primary : muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            for (final customDir in vaults.customDirectories) ...[
              _buildCustomDirectoryCard(
                directory: customDir,
                isEnabled: isCustom,
                isPicking: _pickingTarget == customDir.name,
                theme: theme,
                primary: primary,
                text: text,
                muted: muted,
                cardBg: cardBg,
                subtleBorder: subtleBorder,
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  /// 1st Card: One Vault with Custom Vaults Toggle
  Widget _buildOneVaultCard({
    required ThemeData theme,
    required VaultsState vaults,
    required bool isCustom,
    required Color primary,
    required Color? text,
    required Color? muted,
    required Color cardBg,
    required Color subtleBorder,
  }) {
    final oneVaultPath = vaults.oneVaultPath;
    final hasPath = oneVaultPath != null && oneVaultPath.isNotEmpty;
    final folderName = hasPath
        ? (p.basename(oneVaultPath).isEmpty
            ? oneVaultPath
            : p.basename(oneVaultPath))
        : 'No folder selected';

    // When isCustom is true, One Vault is greyed out
    final isEnabled = !isCustom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled && hasPath
              ? primary.withValues(alpha: 0.35)
              : subtleBorder,
          width: isEnabled && hasPath ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title, Icon and Custom Vaults Toggle
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? primary.withValues(alpha: 0.14)
                      : (theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.all_inclusive_rounded,
                  color: isEnabled ? primary : muted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One Vault',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? folderName
                          : 'Greyed out (Custom Vaults Active)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Custom Vaults Toggle Switch
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Custom vaults',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Switch.adaptive(
                    value: isCustom,
                    activeTrackColor: primary,
                    onChanged: (val) {
                      ref.read(vaultsProvider.notifier).toggleCustomVaults(val);
                      ref.invalidate(feedItemsProvider);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Location details (animated opacity if greyed out)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isEnabled ? 1.0 : 0.4,
            child: IgnorePointer(
              ignoring: !isEnabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (hasPath) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              oneVaultPath,
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: muted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.copy_rounded,
                                size: 16, color: muted),
                            tooltip: 'Copy path',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: oneVaultPath));
                              _showToast('Path copied to clipboard');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Change Location Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickingTarget == 'One Vault'
                          ? null
                          : () => _pickDirectory(
                                targetName: 'One Vault',
                                onSelected: (p) async {
                                  await ref
                                      .read(vaultsProvider.notifier)
                                      .setOneVaultPath(p);
                                  await ref
                                      .read(selectedFolderProvider.notifier)
                                      .setFolderPath(p);
                                },
                              ),
                      icon: _pickingTarget == 'One Vault'
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open_rounded, size: 16),
                      label: Text(
                        hasPath ? 'Change Location' : 'Select Location',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        side: BorderSide(color: subtleBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  /// Reusable card for Cards 2 to 6
  Widget _buildVaultCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? path,
    required bool isEnabled,
    required String disabledHint,
    required bool isPicking,
    required VoidCallback onPick,
    required ThemeData theme,
    required Color primary,
    required Color? text,
    required Color? muted,
    required Color cardBg,
    required Color subtleBorder,
  }) {
    final hasPath = path != null && path.isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEnabled && hasPath
                ? primary.withValues(alpha: 0.25)
                : subtleBorder,
            width: isEnabled && hasPath ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? primary.withValues(alpha: 0.12)
                        : (theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isEnabled ? primary : muted,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEnabled ? subtitle : disabledHint,
                        style: GoogleFonts.inter(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                // Location Button
                IgnorePointer(
                  ignoring: !isEnabled,
                  child: ElevatedButton.icon(
                    onPressed: isPicking ? null : onPick,
                    icon: isPicking
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open_rounded, size: 14),
                    label: Text(
                      hasPath ? 'Change' : 'Select',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled && hasPath
                          ? primary
                          : (theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      foregroundColor: isEnabled && hasPath
                          ? theme.scaffoldBackgroundColor
                          : text,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (isEnabled && hasPath) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        path,
                        style: GoogleFonts.robotoMono(
                          fontSize: 10.5,
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, size: 14, color: muted),
                      tooltip: 'Copy path',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: path));
                        _showToast('Path copied to clipboard');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Custom Directory Card with Type selector and Delete button
  Widget _buildCustomDirectoryCard({
    required CustomDirectory directory,
    required bool isEnabled,
    required bool isPicking,
    required ThemeData theme,
    required Color primary,
    required Color? text,
    required Color? muted,
    required Color cardBg,
    required Color subtleBorder,
  }) {
    final hasPath = directory.path != null && directory.path!.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEnabled && hasPath
                ? primary.withValues(alpha: 0.25)
                : subtleBorder,
            width: isEnabled && hasPath ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Directory Icon (matches chosen DirectoryType)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? primary.withValues(alpha: 0.12)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    directory.type.icon,
                    size: 20,
                    color: isEnabled ? primary : muted,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with rename icon
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              directory.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isEnabled) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: () => _showRenameCustomDialog(
                                directory.id,
                                directory.name,
                              ),
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 15,
                                color: muted,
                              ),
                              tooltip: 'Rename',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Directory Type Selector Popup Pill
                      IgnorePointer(
                        ignoring: !isEnabled,
                        child: PopupMenuButton<DirectoryType>(
                          initialValue: directory.type,
                          tooltip: 'Change type',
                          elevation: 3,
                          color: isDark ? const Color(0xFF222222) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: subtleBorder),
                          ),
                          onSelected: (DirectoryType newType) async {
                            await ref
                                .read(vaultsProvider.notifier)
                                .updateCustomDirectoryType(
                                    directory.id, newType);
                            ref.invalidate(feedItemsProvider);
                            _showToast('Type updated to ${newType.displayName}');
                          },
                          itemBuilder: (context) => DirectoryType.values
                              .map(
                                (type) => PopupMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        type.icon,
                                        size: 16,
                                        color: type == directory.type
                                            ? primary
                                            : muted,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        type.displayName,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: type == directory.type
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: type == directory.type
                                              ? primary
                                              : text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isEnabled
                                  ? primary.withValues(alpha: 0.12)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  directory.type.icon,
                                  size: 11,
                                  color: isEnabled ? primary : muted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  directory.type.displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isEnabled ? primary : muted,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: 14,
                                  color: isEnabled ? primary : muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete Button (if enabled)
                if (isEnabled) ...[
                  IconButton(
                    onPressed: () => _showDeleteCustomDialog(directory),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: muted?.withValues(alpha: 0.7),
                    ),
                    tooltip: 'Delete directory',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                ],

                // Location Picker Button
                IgnorePointer(
                  ignoring: !isEnabled,
                  child: ElevatedButton.icon(
                    onPressed: isPicking
                        ? null
                        : () => _pickDirectory(
                              targetName: directory.name,
                              onSelected: (p) async {
                                await ref
                                    .read(vaultsProvider.notifier)
                                    .updateCustomDirectoryPath(
                                        directory.id, p);
                              },
                            ),
                    icon: isPicking
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open_rounded, size: 14),
                    label: Text(
                      hasPath ? 'Change' : 'Select',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnabled && hasPath
                          ? primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06)),
                      foregroundColor: isEnabled && hasPath
                          ? theme.scaffoldBackgroundColor
                          : text,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (isEnabled && hasPath) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        directory.path!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 10.5,
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, size: 14, color: muted),
                      tooltip: 'Copy path',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: directory.path!));
                        _showToast('Path copied to clipboard');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
