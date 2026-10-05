import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_item.dart';
import '../models/custom_directory.dart';

/// Service to handle local folder selection and reading/writing Markdown files.
class LocalFolderService {
  static const String _folderKey = 'selected_markdown_folder_path';

  /// Request storage permissions on Android.
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          final status = await Permission.storage.request();
          debugPrint('Storage permission status: $status');
        }
        if (await Permission.manageExternalStorage.isDenied) {
          final status = await Permission.manageExternalStorage.request();
          debugPrint('Manage external storage status: $status');
        }
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  /// Resolves Android SAF Content URIs into accessible filesystem paths.
  String resolvePath(String rawPath) {
    if (rawPath.startsWith('content://')) {
      try {
        final decoded = Uri.decodeFull(rawPath);
        if (decoded.contains('primary:')) {
          final relativePath = decoded.split('primary:').last;
          final resolved = p.join('/storage/emulated/0', relativePath);
          debugPrint('Resolved SAF URI "$rawPath" -> "$resolved"');
          return resolved;
        } else {
          final treeIndex = decoded.indexOf('/tree/');
          if (treeIndex != -1) {
            final treePart = decoded.substring(treeIndex + 6);
            if (treePart.contains(':')) {
              final parts = treePart.split(':');
              final storageId = parts.first;
              final relativePath = parts.sublist(1).join(':');
              if (storageId != 'primary') {
                return p.join('/storage', storageId, relativePath);
              }
              return p.join('/storage/emulated/0', relativePath);
            }
          }
        }
      } catch (e) {
        debugPrint('Error resolving SAF URI "$rawPath": $e');
      }
    }
    return rawPath;
  }

  /// Get the currently saved folder path from SharedPreferences.
  Future<String?> getSelectedFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPath = prefs.getString(_folderKey);
    if (rawPath != null && rawPath.isNotEmpty) {
      final path = resolvePath(rawPath);
      final dir = Directory(path);
      try {
        if (await dir.exists()) {
          return path;
        } else {
          debugPrint('Directory does not exist at resolved path: $path');
        }
      } catch (e) {
        debugPrint('Error checking directory existence for $path: $e');
      }
    }
    return null;
  }

  /// Save selected folder path to SharedPreferences.
  Future<void> setSelectedFolderPath(String rawPath) async {
    final prefs = await SharedPreferences.getInstance();
    final path = resolvePath(rawPath);
    await prefs.setString(_folderKey, path);
  }

  /// Get fallback local directory (App Documents / InterceptorFeed) if user hasn't chosen one.
  Future<String> getDefaultFolderPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    final defaultDir = Directory(p.join(docDir.path, 'InterceptorFeed'));
    if (!await defaultDir.exists()) {
      await defaultDir.create(recursive: true);
    }
    return defaultDir.path;
  }

  /// Load all markdown files from the target directory resiliently.
  Future<List<FeedItem>> loadMarkdownItems([String? folderPath]) async {
    await requestPermissions();

    final rawTarget = folderPath ??
        await getSelectedFolderPath() ??
        await getDefaultFolderPath();

    final targetPath = resolvePath(rawTarget);
    debugPrint('Loading markdown items from targetPath: $targetPath');

    final dir = Directory(targetPath);
    try {
      if (!await dir.exists()) {
        debugPrint('Target directory does not exist: $targetPath');
        return [];
      }
    } catch (e) {
      debugPrint('Error verifying directory existence: $e');
      return [];
    }

    List<FeedItem> items = [];

    // Helper to process entity
    Future<void> processEntity(FileSystemEntity entity) async {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        final isMarkdown = ext == '.md' ||
            ext == '.markdown' ||
            ext == '.txt' ||
            ext == '.mdown' ||
            ext == '.mkd' ||
            ext == '.mkdn';

        if (isMarkdown) {
          try {
            final bytes = await entity.readAsBytes();
            if (bytes.isEmpty) return;

            final content = utf8.decode(bytes, allowMalformed: true);
            final stat = await entity.stat();

            items.add(
              FeedItem(
                id: entity.path,
                userId: 'local_user',
                type: ContentType.text,
                content: content,
                note: null,
                createdAt: stat.modified,
                sourceUrl: entity.path,
              ),
            );
            debugPrint('Successfully loaded markdown file: ${entity.path}');
          } catch (e) {
            debugPrint('Failed to read file ${entity.path}: $e');
          }
        }
      }
    }

    // Try recursive async stream listing first
    try {
      final stream = dir.list(recursive: true, followLinks: false);
      await for (final entity in stream.handleError((error) {
        debugPrint('Skipping inaccessible file/directory: $error');
      })) {
        await processEntity(entity);
      }
    } catch (e) {
      debugPrint('Async stream list exception: $e. Falling back to top-level scan.');
    }

    // Fallback: If 0 items loaded, try top-level listSync / list(recursive: false)
    if (items.isEmpty) {
      try {
        final topEntities = await dir.list(recursive: false).toList();
        for (final entity in topEntities) {
          await processEntity(entity);
        }
      } catch (e) {
        debugPrint('Top level scan error: $e');
      }
    }

    // Sort by modified timestamp (newest first)
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('Loaded ${items.length} markdown items total.');

    return items;
  }

  /// Load quotes (text/markdown files) from directory.
  Future<List<FeedItem>> loadQuotesItems([String? folderPath]) async {
    if (folderPath == null || folderPath.isEmpty) return [];
    return loadMarkdownItems(folderPath);
  }

  /// Load images from directory.
  Future<List<FeedItem>> loadImagesItems([String? folderPath]) async {
    if (folderPath == null || folderPath.isEmpty) return [];
    await requestPermissions();

    final targetPath = resolvePath(folderPath);
    final dir = Directory(targetPath);
    try {
      if (!await dir.exists()) return [];
    } catch (_) {
      return [];
    }

    final allowed = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'};
    List<FeedItem> items = [];

    Future<void> process(FileSystemEntity entity) async {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (allowed.contains(ext)) {
          try {
            final stat = await entity.stat();
            items.add(
              FeedItem(
                id: entity.path,
                userId: 'local_user',
                type: ContentType.image,
                content: entity.path,
                note: null,
                createdAt: stat.modified,
                sourceUrl: entity.path,
              ),
            );
          } catch (_) {}
        }
      }
    }

    try {
      final stream = dir.list(recursive: true, followLinks: false);
      await for (final entity in stream.handleError((_) {})) {
        await process(entity);
      }
    } catch (_) {}

    if (items.isEmpty) {
      try {
        final topEntities = await dir.list(recursive: false).toList();
        for (final entity in topEntities) {
          await process(entity);
        }
      } catch (_) {}
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Load videos from directory.
  Future<List<FeedItem>> loadVideosItems([String? folderPath]) async {
    if (folderPath == null || folderPath.isEmpty) return [];
    await requestPermissions();

    final targetPath = resolvePath(folderPath);
    final dir = Directory(targetPath);
    try {
      if (!await dir.exists()) return [];
    } catch (_) {
      return [];
    }

    final allowed = {'.mp4', '.mov', '.mkv', '.webm', '.avi', '.3gp'};
    List<FeedItem> items = [];

    Future<void> process(FileSystemEntity entity) async {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (allowed.contains(ext)) {
          try {
            final stat = await entity.stat();
            items.add(
              FeedItem(
                id: entity.path,
                userId: 'local_user',
                type: ContentType.video,
                content: entity.path,
                note: null,
                createdAt: stat.modified,
                sourceUrl: entity.path,
              ),
            );
          } catch (_) {}
        }
      }
    }

    try {
      final stream = dir.list(recursive: true, followLinks: false);
      await for (final entity in stream.handleError((_) {})) {
        await process(entity);
      }
    } catch (_) {}

    if (items.isEmpty) {
      try {
        final topEntities = await dir.list(recursive: false).toList();
        for (final entity in topEntities) {
          await process(entity);
        }
      } catch (_) {}
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Load audio files from directory.
  Future<List<FeedItem>> loadAudiosItems([String? folderPath]) async {
    if (folderPath == null || folderPath.isEmpty) return [];
    await requestPermissions();

    final targetPath = resolvePath(folderPath);
    final dir = Directory(targetPath);
    try {
      if (!await dir.exists()) return [];
    } catch (_) {
      return [];
    }

    final allowed = {'.mp3', '.wav', '.m4a', '.aac', '.flac', '.ogg'};
    List<FeedItem> items = [];

    Future<void> process(FileSystemEntity entity) async {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (allowed.contains(ext)) {
          try {
            final stat = await entity.stat();
            items.add(
              FeedItem(
                id: entity.path,
                userId: 'local_user',
                type: ContentType.audio,
                content: entity.path,
                note: null,
                createdAt: stat.modified,
                sourceUrl: entity.path,
              ),
            );
          } catch (_) {}
        }
      }
    }

    try {
      final stream = dir.list(recursive: true, followLinks: false);
      await for (final entity in stream.handleError((_) {})) {
        await process(entity);
      }
    } catch (_) {}

    if (items.isEmpty) {
      try {
        final topEntities = await dir.list(recursive: false).toList();
        for (final entity in topEntities) {
          await process(entity);
        }
      } catch (_) {}
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Load files from custom directory according to its DirectoryType.
  Future<List<FeedItem>> loadCustomItems(
    String? folderPath, [
    DirectoryType type = DirectoryType.mixed,
  ]) async {
    if (folderPath == null || folderPath.isEmpty) return [];
    switch (type) {
      case DirectoryType.notes:
        return loadMarkdownItems(folderPath);
      case DirectoryType.quotes:
        return loadQuotesItems(folderPath);
      case DirectoryType.images:
        return loadImagesItems(folderPath);
      case DirectoryType.videos:
        return loadVideosItems(folderPath);
      case DirectoryType.audios:
        return loadAudiosItems(folderPath);
      case DirectoryType.mixed:
        final textItems = await loadMarkdownItems(folderPath);
        final imageItems = await loadImagesItems(folderPath);
        final videoItems = await loadVideosItems(folderPath);
        final audioItems = await loadAudiosItems(folderPath);

        final all = [...textItems, ...imageItems, ...videoItems, ...audioItems];
        all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return all;
    }
  }

  /// Create a new Markdown file in the active folder.
  Future<FeedItem> createMarkdownNote({
    required String title,
    required String content,
    String? note,
    String? folderPath,
  }) async {
    await requestPermissions();

    final rawTarget = folderPath ??
        await getSelectedFolderPath() ??
        await getDefaultFolderPath();

    final targetPath = resolvePath(rawTarget);
    final dir = Directory(targetPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Sanitize title for filename
    String filename = title
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    if (filename.isEmpty) {
      filename = 'Note_${DateTime.now().millisecondsSinceEpoch}';
    }

    String filePath = p.join(dir.path, '$filename.md');
    File file = File(filePath);

    int counter = 1;
    while (await file.exists()) {
      filePath = p.join(dir.path, '${filename}_$counter.md');
      file = File(filePath);
      counter++;
    }

    // Format final markdown string
    StringBuffer sb = StringBuffer();
    if (!content.startsWith('#')) {
      sb.writeln('# $title\n');
    }
    sb.write(content);

    if (note != null && note.isNotEmpty) {
      sb.writeln('\n\n---\n*Note: $note*');
    }

    await file.writeAsString(sb.toString());
    final stat = await file.stat();

    return FeedItem(
      id: file.path,
      userId: 'local_user',
      type: ContentType.text,
      content: sb.toString(),
      note: null,
      createdAt: stat.modified,
      sourceUrl: file.path,
    );
  }

  /// Delete a markdown file by path.
  Future<void> deleteMarkdownNote(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
