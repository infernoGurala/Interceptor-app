import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';
import '../providers/vaults_provider.dart';

/// Screen allowing users to customize and toggle their revision feed sources:
/// Notes, Quotes, Images, Videos, Audios, and Custom Directory.
class ReviseScreen extends ConsumerWidget {
  const ReviseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final vaultsNotifier = ref.read(vaultsProvider.notifier);
    final feedAsync = ref.watch(feedItemsProvider);
    final itemCount = feedAsync.value?.length ?? 0;

    final oneVaultPath = vaults.oneVaultPath;
    final folderName = vaults.isCustomVaults
        ? 'Custom Vaults'
        : (oneVaultPath != null && oneVaultPath.isNotEmpty
            ? (p.basename(oneVaultPath).isEmpty
                ? oneVaultPath
                : p.basename(oneVaultPath))
            : 'One Vault');

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
                        'Revise',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Toggle sources applied to your feed',
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

            // Active Vault Mode Status Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: subtleBorder),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      vaults.isCustomVaults
                          ? Icons.dashboard_customize_rounded
                          : Icons.all_inclusive_rounded,
                      color: primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folderName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          itemCount > 0
                              ? '$itemCount items active in feed'
                              : 'Feed is currently empty',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Section Header
            Text(
              'FEED SOURCES',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: muted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Notes Toggle
            _buildSourceToggleCard(
              title: 'Notes',
              subtitle: 'Markdown notes (.md, .txt)',
              icon: Icons.article_outlined,
              value: vaults.enableNotes,
              onChanged: (val) {
                vaultsNotifier.toggleNotes(val);
                ref.invalidate(feedItemsProvider);
              },
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 2. Quotes Toggle
            _buildSourceToggleCard(
              title: 'Quotes',
              subtitle: 'Quotes and highlights collection',
              icon: Icons.format_quote_rounded,
              value: vaults.enableQuotes,
              onChanged: (val) {
                vaultsNotifier.toggleQuotes(val);
                ref.invalidate(feedItemsProvider);
              },
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 3. Images Toggle
            _buildSourceToggleCard(
              title: 'Images',
              subtitle: 'Photos, diagrams, and visual captures',
              icon: Icons.image_outlined,
              value: vaults.enableImages,
              onChanged: (val) {
                vaultsNotifier.toggleImages(val);
                ref.invalidate(feedItemsProvider);
              },
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 4. Videos Toggle
            _buildSourceToggleCard(
              title: 'Videos',
              subtitle: 'Short video clips and recordings',
              icon: Icons.video_library_outlined,
              value: vaults.enableVideos,
              onChanged: (val) {
                vaultsNotifier.toggleVideos(val);
                ref.invalidate(feedItemsProvider);
              },
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 5. Audios Toggle
            _buildSourceToggleCard(
              title: 'Audios',
              subtitle: 'Voice notes, podcasts, and sounds',
              icon: Icons.headphones_outlined,
              value: vaults.enableAudios,
              onChanged: (val) {
                vaultsNotifier.toggleAudios(val);
                ref.invalidate(feedItemsProvider);
              },
              theme: theme,
              primary: primary,
              text: text,
              muted: muted,
              cardBg: cardBg,
              subtleBorder: subtleBorder,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 6. Custom Directory Toggles (Infinite amount)
            if (vaults.customDirectories.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'CUSTOM DIRECTORIES',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: muted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),
              for (final customDir in vaults.customDirectories) ...[
                _buildSourceToggleCard(
                  title: customDir.name,
                  subtitle: customDir.path != null && customDir.path!.isNotEmpty
                      ? '${customDir.type.displayName} • ${p.basename(customDir.path!)}'
                      : '${customDir.type.displayName} • (No location selected)',
                  icon: customDir.type.icon,
                  value: customDir.isEnabled,
                  onChanged: (val) {
                    vaultsNotifier.toggleCustomDirectory(customDir.id, val);
                    ref.invalidate(feedItemsProvider);
                  },
                  theme: theme,
                  primary: primary,
                  text: text,
                  muted: muted,
                  cardBg: cardBg,
                  subtleBorder: subtleBorder,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 16),

            // Action: Open Feed
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currentTabProvider.notifier).state = 1;
              },
              icon: const Icon(Icons.space_dashboard_rounded, size: 18),
              label: Text(
                'Open Feed',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
    required Color primary,
    required Color? text,
    required Color? muted,
    required Color cardBg,
    required Color subtleBorder,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value ? primary.withValues(alpha: 0.3) : subtleBorder,
          width: value ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? primary.withValues(alpha: 0.14)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? primary : muted,
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
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
