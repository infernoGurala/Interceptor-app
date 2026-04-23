import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import '../services/cloudinary_service.dart';
import '../services/cobalt_service.dart';
import '../services/instagram_service.dart';
import '../services/local_cache_service.dart';
import '../models/feed_item.dart';
import '../utils/feed_randomizer.dart';
import '../utils/connectivity.dart';

// ─────────────────────────────────────
// Supabase client provider
// ─────────────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// ─────────────────────────────────────
// Service providers
// ─────────────────────────────────────
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.read(supabaseClientProvider)),
);

final feedServiceProvider = Provider<FeedService>(
  (ref) => FeedService(ref.read(supabaseClientProvider)),
);

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(),
);

final cobaltServiceProvider = Provider<CobaltService>(
  (ref) => CobaltService(),
);

final instagramServiceProvider = Provider<InstagramService>(
  (ref) => InstagramService(),
);

final localCacheServiceProvider = Provider<LocalCacheService>(
  (ref) => LocalCacheService(),
);

// ─────────────────────────────────────
// Auth state provider
// ─────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.read(supabaseClientProvider).auth.currentUser;
});

// ─────────────────────────────────────
// Feed content type filter
// ─────────────────────────────────────
enum FeedFilter { all, text, image, video }

final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);

// ─────────────────────────────────────
// Feed items provider
// ─────────────────────────────────────
final feedItemsProvider = FutureProvider<List<FeedItem>>((ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return [];

  final connected = await isConnected();
  final feedService = ref.read(feedServiceProvider);
  final cacheService = ref.read(localCacheServiceProvider);

  List<FeedItem> items;

  if (connected) {
    try {
      items = await feedService.fetchFeedItems(user.id);
      // Cache text items for offline use
      final textItems =
          items.where((i) => i.type == ContentType.text).toList();
      await cacheService.cacheItems(textItems);

      // Sync any pending offline items
      final unsynced = await cacheService.getUnsyncedItems();
      for (final item in unsynced) {
        try {
          await feedService.createFeedItem(item);
          await cacheService.markSynced(item.id);
        } catch (_) {
          // Will retry on next sync
        }
      }
    } catch (e) {
      // Fall back to cache
      items = await cacheService.getAllCachedItems(user.id);
    }
  } else {
    // Offline: only text items from cache
    items = await cacheService.getCachedTextItems(user.id);
  }

  // Apply filter
  final filter = ref.read(feedFilterProvider);
  if (filter != FeedFilter.all) {
    items = items.where((item) {
      switch (filter) {
        case FeedFilter.text:
          return item.type == ContentType.text;
        case FeedFilter.image:
          return item.type == ContentType.image;
        case FeedFilter.video:
          return item.type == ContentType.video;
        default:
          return true;
      }
    }).toList();
  }

  // Randomize with 10-item gap constraint
  return FeedRandomizer.shuffle(items);
});

// ─────────────────────────────────────
// Bottom nav bar visibility
// ─────────────────────────────────────
final navBarVisibleProvider = StateProvider<bool>((ref) => true);

// ─────────────────────────────────────
// Current tab index
// ─────────────────────────────────────
final currentTabProvider = StateProvider<int>((ref) => 0);
