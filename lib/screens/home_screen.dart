import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/glassmorphic_nav_bar.dart';
import 'hub_screen.dart';
import 'intercept_screen.dart';
import 'jet_screen.dart';
import 'profile_screen.dart';

/// Main shell with 4 tabs and floating glassmorphic bottom nav bar.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
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
                if (index != 1) {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                }
                ref.read(navBarVisibleProvider.notifier).state = true;
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
        return const HubScreen(key: ValueKey('hub'));
      case 1:
        return const InterceptScreen(key: ValueKey('intercept'));
      case 2:
        return const JetScreen(key: ValueKey('jet'));
      case 3:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const HubScreen(key: ValueKey('hub'));
    }
  }
}
