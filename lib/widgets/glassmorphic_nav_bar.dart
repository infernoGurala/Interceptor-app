import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

/// A floating, glassmorphic bottom navigation bar.
/// Hides on scroll-down, shows on scroll-up.
class GlassmorphicNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassmorphicNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final isExpanded = ref.watch(navBarVisibleProvider);
    final isHidden = isKeyboardOpen;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double expandedWidth = screenWidth - 120; // 60 padding on left and right
    final double collapsedWidth = 56; // 56x56 FAB size circle

    IconData activeIcon;
    switch (currentIndex) {
      case 0:
        activeIcon = Icons.space_dashboard_rounded;
        break;
      case 1:
        activeIcon = Icons.bolt_rounded;
        break;
      case 2:
        activeIcon = Icons.person_rounded;
        break;
      default:
        activeIcon = Icons.space_dashboard_rounded;
        break;
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: isHidden ? const Offset(0, 1.5) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isHidden ? 0.0 : 1.0,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(
            isExpanded ? 60 : screenWidth - collapsedWidth - 16,
            0,
            isExpanded ? 60 : 16,
            24,
          ),
          child: GestureDetector(
            onTap: () {
              if (!isExpanded) {
                ref.read(navBarVisibleProvider.notifier).state = true;
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: isExpanded ? 64 : collapsedWidth,
                  width: isExpanded ? expandedWidth : collapsedWidth,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Collapsed State Icon
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isExpanded ? 0.0 : 1.0,
                        child: Icon(activeIcon, color: accent),
                      ),
                      
                      // Expanded State Row
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !isExpanded,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: expandedWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _NavItem(
                                    icon: Icons.space_dashboard_outlined,
                                    activeIcon: Icons.space_dashboard_rounded,
                                    label: 'Intercept',
                                    isActive: currentIndex == 0,
                                    accent: accent,
                                    onTap: () => onTap(0),
                                  ),
                                  _NavItem(
                                    icon: Icons.bolt_outlined,
                                    activeIcon: Icons.bolt_rounded,
                                    label: 'Jet',
                                    isActive: currentIndex == 1,
                                    accent: accent,
                                    onTap: () => onTap(1),
                                  ),
                                  _NavItem(
                                    icon: Icons.person_outline_rounded,
                                    activeIcon: Icons.person_rounded,
                                    label: 'Profile',
                                    isActive: currentIndex == 2,
                                    accent: accent,
                                    onTap: () => onTap(2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive
                    ? accent
                    : Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
