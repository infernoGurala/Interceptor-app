/// The type of content in a feed item.
enum ContentType {
  text,
  image,
  video;

  /// Convert from string (stored in Supabase).
  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentType.text,
    );
  }
}

/// A single content item in the user's personal feed.
class FeedItem {
  final String id;
  final String userId;
  final ContentType type;
  final String content; // markdown text or Cloudinary/media URL
  final String? note; // private note attached to the item
  final DateTime createdAt;
  final String? sourceUrl; // original platform link (Instagram, YouTube, etc.)

  const FeedItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.note,
    required this.createdAt,
    this.sourceUrl,
  });

  /// Create from Supabase row.
  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: ContentType.fromString(map['type'] as String),
      content: map['content'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      sourceUrl: map['source_url'] as String?,
    );
  }

  /// Convert to map for Supabase insert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'content': content,
      'note': note,
      'source_url': sourceUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields.
  FeedItem copyWith({
    String? id,
    String? userId,
    ContentType? type,
    String? content,
    String? note,
    DateTime? createdAt,
    String? sourceUrl,
  }) {
    return FeedItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
