import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

/// Animated splash screen shown on app launch.
/// Checks auth state and navigates accordingly.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Glowing Aura
          Positioned.fill(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphic Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.blur_on_rounded, // Cool abstract icon
                          color: theme.textTheme.bodyLarge?.color,
                          size: 54,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 1000.ms,
                      curve: Curves.easeOutBack,
                    )
                    .shimmer(
                      delay: 500.ms,
                      duration: 1500.ms,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                const SizedBox(height: 32),

                // Cinematic Typography
                Text(
                  'INTERCEPTOR',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                    letterSpacing: 8,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 800.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 400.ms,
                      duration: 800.ms,
                      curve: Curves.easeOutQuint,
                    ),

                // Tagline
                Text(
                  'TAKE CONTROL',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
