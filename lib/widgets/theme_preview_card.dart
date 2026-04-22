import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

/// A live preview card for a theme in the theme picker.
class ThemePreviewCard extends StatelessWidget {
  final String themeName;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.themeName,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppThemes.getBaseColor(themeName, isDark);
    final accentColor = AppThemes.getAccentColor(themeName, isDark);
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9);
    final subtextColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme name
            Text(
              themeName,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Fake content lines
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: subtextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                color: subtextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            // Accent color dot
            Row(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
