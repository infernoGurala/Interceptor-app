import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feed_item.dart';

/// CRUD operations for feed items stored in Supabase.
class FeedService {
  final SupabaseClient _client;

  FeedService(this._client);

  /// Fetch all feed items for the given user.
  Future<List<FeedItem>> fetchFeedItems(String userId) async {
    final response = await _client
        .from('feed_items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => FeedItem.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Create a new feed item.
  Future<FeedItem> createFeedItem(FeedItem item) async {
    final response = await _client
        .from('feed_items')
        .insert(item.toMap())
        .select()
        .single();

    return FeedItem.fromMap(response);
  }

  /// Delete a feed item by ID.
  Future<void> deleteFeedItem(String id) async {
    await _client.from('feed_items').delete().eq('id', id);
  }

  /// Update the private note on a feed item.
  Future<void> updateNote(String id, String? note) async {
    await _client.from('feed_items').update({'note': note}).eq('id', id);
  }

  /// Update an entire feed item.
  Future<void> updateFeedItem(FeedItem item) async {
    await _client.from('feed_items').update(item.toMap()).eq('id', item.id);
  }
}
