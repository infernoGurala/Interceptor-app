import 'dart:math';
import '../models/feed_item.dart';

/// Randomizes feed order with a constraint: the same item
/// cannot appear within 10 positions of itself.
class FeedRandomizer {
  static final _random = Random();

  /// Shuffle feed items with a 10-item gap constraint.
  /// This ensures that the same content item won't appear
  /// within 10 cards of itself in a single session.
  static List<FeedItem> shuffle(List<FeedItem> items) {
    if (items.length <= 10) {
      // If we have 10 or fewer items, a simple shuffle is fine
      final shuffled = List<FeedItem>.from(items);
      shuffled.shuffle(_random);
      return shuffled;
    }

    final result = <FeedItem>[];
    final remaining = List<FeedItem>.from(items);

    while (remaining.isNotEmpty) {
      // Filter out items that appeared in the last 10 positions
      final recentIds = result
          .skip(result.length > 10 ? result.length - 10 : 0)
          .map((e) => e.id)
          .toSet();

      final eligible = remaining
          .where((item) => !recentIds.contains(item.id))
          .toList();

      if (eligible.isEmpty) {
        // Fallback: if all remaining items are in the recent window,
        // just pick randomly from remaining
        final index = _random.nextInt(remaining.length);
        result.add(remaining.removeAt(index));
      } else {
        final index = _random.nextInt(eligible.length);
        final chosen = eligible[index];
        result.add(chosen);
        remaining.remove(chosen);
      }
    }

    return result;
  }
}
