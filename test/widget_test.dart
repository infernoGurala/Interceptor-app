import 'package:flutter_test/flutter_test.dart';
import 'package:interceptor/models/feed_item.dart';
import 'package:interceptor/utils/feed_randomizer.dart';

void main() {
  group('FeedRandomizer', () {
    test('should return all items', () {
      final items = List.generate(
        20,
        (i) => FeedItem(
          id: 'item_$i',
          userId: 'user_1',
          type: ContentType.text,
          content: 'Content $i',
          createdAt: DateTime.now(),
        ),
      );

      final shuffled = FeedRandomizer.shuffle(items);
      expect(shuffled.length, items.length);
      expect(shuffled.map((e) => e.id).toSet(), items.map((e) => e.id).toSet());
    });

    test('should handle empty list', () {
      final shuffled = FeedRandomizer.shuffle([]);
      expect(shuffled, isEmpty);
    });

    test('should handle small list', () {
      final items = List.generate(
        3,
        (i) => FeedItem(
          id: 'item_$i',
          userId: 'user_1',
          type: ContentType.text,
          content: 'Content $i',
          createdAt: DateTime.now(),
        ),
      );

      final shuffled = FeedRandomizer.shuffle(items);
      expect(shuffled.length, 3);
    });
  });
}
