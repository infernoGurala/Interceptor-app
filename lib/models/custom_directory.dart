import 'package:flutter/material.dart';

/// The type/category of content stored in a directory.
enum DirectoryType {
  mixed,
  notes,
  quotes,
  images,
  videos,
  audios;

  String get displayName {
    switch (this) {
      case DirectoryType.mixed:
        return 'Mixed (All)';
      case DirectoryType.notes:
        return 'Notes';
      case DirectoryType.quotes:
        return 'Quotes';
      case DirectoryType.images:
        return 'Images';
      case DirectoryType.videos:
        return 'Videos';
      case DirectoryType.audios:
        return 'Audios';
    }
  }

  IconData get icon {
    switch (this) {
      case DirectoryType.mixed:
        return Icons.folder_copy_outlined;
      case DirectoryType.notes:
        return Icons.article_outlined;
      case DirectoryType.quotes:
        return Icons.format_quote_rounded;
      case DirectoryType.images:
        return Icons.image_outlined;
      case DirectoryType.videos:
        return Icons.video_library_outlined;
      case DirectoryType.audios:
        return Icons.headphones_outlined;
    }
  }

  static DirectoryType fromString(String? val) {
    if (val == null) return DirectoryType.mixed;
    return DirectoryType.values.firstWhere(
      (e) => e.name == val.toLowerCase(),
      orElse: () => DirectoryType.mixed,
    );
  }
}

/// A user-defined custom directory with customizable name, location, and type.
class CustomDirectory {
  final String id;
  final String name;
  final String? path;
  final DirectoryType type;
  final bool isEnabled;

  const CustomDirectory({
    required this.id,
    required this.name,
    this.path,
    this.type = DirectoryType.mixed,
    this.isEnabled = true,
  });

  CustomDirectory copyWith({
    String? id,
    String? name,
    String? path,
    DirectoryType? type,
    bool? isEnabled,
  }) {
    return CustomDirectory(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type.name,
        'isEnabled': isEnabled,
      };

  factory CustomDirectory.fromMap(Map<String, dynamic> map) => CustomDirectory(
        id: map['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: map['name'] as String? ?? 'Custom Vault',
        path: map['path'] as String?,
        type: DirectoryType.fromString(map['type'] as String?),
        isEnabled: map['isEnabled'] as bool? ?? true,
      );
}
