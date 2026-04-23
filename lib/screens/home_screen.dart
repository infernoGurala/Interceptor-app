import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/glassmorphic_nav_bar.dart';
import 'intercept_screen.dart';
import 'jet_screen.dart';
import 'profile_screen.dart';

/// Main shell with the three tabs and glassmorphic bottom nav bar.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Screen content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildScreen(currentTab),
          ),

          // Floating glassmorphic nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassmorphicNavBar(
              currentIndex: currentTab,
              onTap: (index) {
                ref.read(currentTabProvider.notifier).state = index;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const InterceptScreen(key: ValueKey('intercept'));
      case 1:
        return const JetScreen(key: ValueKey('jet'));
      case 2:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const InterceptScreen(key: ValueKey('intercept'));
    }
  }
}
