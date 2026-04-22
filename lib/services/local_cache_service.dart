import 'package:sqflite/sqflite.dart';
import '../models/feed_item.dart';

/// SQLite local cache for text/markdown feed items.
/// Enables offline reading and stores pending changes for sync.
class LocalCacheService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/interceptor_cache.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE feed_items_cache (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            type TEXT NOT NULL,
            content TEXT NOT NULL,
            note TEXT,
            source_url TEXT,
            created_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 1,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Cache a list of feed items fetched from Supabase.
  Future<void> cacheItems(List<FeedItem> items) async {
    final db = await database;
    final batch = db.batch();

    for (final item in items) {
      batch.insert(
        'feed_items_cache',
        {
          ...item.toMap(),
          'is_synced': 1,
          'is_deleted': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all cached text items for offline display.
  Future<List<FeedItem>> getCachedTextItems(String userId) async {
    final db = await database;
    final rows = await db.query(
      'feed_items_cache',
      where: 'user_id = ? AND type = ? AND is_deleted = 0',
      whereArgs: [userId, 'text'],
    );

    return rows.map((row) => FeedItem.fromMap(row)).toList();
  }

  /// Get all cached items for a user.
  Future<List<FeedItem>> getAllCachedItems(String userId) async {
    final db = await database;
    final rows = await db.query(
      'feed_items_cache',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
    );

    return rows.map((row) => FeedItem.fromMap(row)).toList();
  }

  /// Save an item locally (for offline creation).
  Future<void> saveItemLocally(FeedItem item) async {
    final db = await database;
    await db.insert(
      'feed_items_cache',
      {
        ...item.toMap(),
        'is_synced': 0,
        'is_deleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all unsynced items (created offline).
  Future<List<FeedItem>> getUnsyncedItems() async {
    final db = await database;
    final rows = await db.query(
      'feed_items_cache',
      where: 'is_synced = 0 AND is_deleted = 0',
    );

    return rows.map((row) => FeedItem.fromMap(row)).toList();
  }

  /// Mark an item as synced.
  Future<void> markSynced(String id) async {
    final db = await database;
    await db.update(
      'feed_items_cache',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark an item as deleted locally.
  Future<void> markDeleted(String id) async {
    final db = await database;
    await db.update(
      'feed_items_cache',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all cached data for a user (on sign out).
  Future<void> clearCache(String userId) async {
    final db = await database;
    await db.delete(
      'feed_items_cache',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Clear entire cache.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('feed_items_cache');
  }
}
