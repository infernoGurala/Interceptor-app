import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../providers/providers.dart';
import '../providers/vaults_provider.dart';
import '../themes/app_fonts.dart';
import '../themes/app_themes.dart';
import '../themes/theme_provider.dart';
import 'manager_screen.dart';

/// Minimal Settings screen — storage folder, appearance, and typography.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _themeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final vaults = ref.watch(vaultsProvider);
    final folderPath = ref.watch(selectedFolderProvider).value;
    final noteCount = ref.watch(feedItemsProvider).value?.length ?? 0;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    final String folderSubtitle;
    if (vaults.isCustomVaults) {
      folderSubtitle = 'Custom Vaults';
    } else if (folderPath != null) {
      folderSubtitle = p.basename(folderPath).isEmpty ? folderPath : p.basename(folderPath);
    } else {
      folderSubtitle = 'Configure directory';
    }

    final currentThemes =
        AppThemes.getFilteredThemes(themeState.isDark, _themeFilter);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
          children: [
            Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Storage
            _Label('Storage', color: muted),
            const SizedBox(height: 12),
            _Group(children: [
              _Row(
                icon: Icons.folder_open_outlined,
                title: 'Manager',
                subtitle: folderSubtitle,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Value('$noteCount items'),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManagerScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 32),

            // Appearance
            _Label('Appearance', color: muted),
            const SizedBox(height: 12),
            _Group(children: [
              _Row(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                trailing: Switch.adaptive(
                  value: themeState.isDark,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: (v) =>
                      ref.read(themeProvider.notifier).setDarkMode(v),
                ),
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setDarkMode(!themeState.isDark),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20, color: muted),
                        const SizedBox(width: 14),
                        Text(
                          'Theme',
                          style: _rowTitle(theme),
                        ),
                        const Spacer(),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _themeFilter,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: muted,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                            dropdownColor: theme.brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'All',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'Dichrome',
                                child: Text('Dichrome'),
                              ),
                              DropdownMenuItem(
                                value: 'Trichrome',
                                child: Text('Trichrome'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _themeFilter = v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (currentThemes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No $_themeFilter themes yet',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: muted,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final name in currentThemes)
                            _Swatch(
                              name: name,
                              base: AppThemes.getBaseColor(
                                  name, themeState.isDark),
                              accent: AppThemes.getAccentColor(
                                  name, themeState.isDark),
                              selected: themeState.themeName.toLowerCase() ==
                                  name.toLowerCase(),
                              onTap: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(name),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 32),

            // Font
            _Label('Font', color: muted),
            const SizedBox(height: 12),
            for (var i = 0; i < AppFonts.presets.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _FontPairBox(
                preset: AppFonts.presets[i],
                isSelected: themeState.fontPair.id == AppFonts.presets[i].id,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setFont(AppFonts.presets[i].id),
              ),
            ],
          ]
              .animate(interval: 40.ms)
              .fadeIn(duration: 300.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }
}

TextStyle _rowTitle(ThemeData theme) => GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: theme.textTheme.bodyLarge?.color,
    );

class _Label extends StatelessWidget {
  final String text;
  final Color? color;
  const _Label(this.text, {this.color});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500, color: color),
      );
}

class _Value extends StatelessWidget {
  final String text;
  const _Value(this.text);

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, color: muted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Grouped flat container with hairline dividers between children.
class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final line = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: line, indent: 52),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: muted),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: _rowTitle(theme)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GoogleFonts.inter(fontSize: 12, color: muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact theme chip with 2-color swatch and theme name.
class _Swatch extends StatelessWidget {
  final String name;
  final Color base;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.name,
    required this.base,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.12)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Two-tone color dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: base,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? theme.textTheme.bodyLarge?.color
                      : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_rounded, size: 14, color: primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rectangular font preview box with live render of selected theme applied to the font pair.
class _FontPairBox extends StatelessWidget {
  final FontPair preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontPairBox({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? primary.withValues(alpha: 0.5)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.headFontName,
                        style: preset.headStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        preset.bodyFontName,
                        style: preset.bodyStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
