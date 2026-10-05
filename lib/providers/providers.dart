import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_folder_service.dart';
import '../models/feed_item.dart';
import 'vaults_provider.dart';

// ─────────────────────────────────────
// Local Folder Service provider
// ─────────────────────────────────────
final localFolderServiceProvider = Provider<LocalFolderService>(
  (ref) => LocalFolderService(),
);

// ─────────────────────────────────────
// Selected Folder Path State Provider
// ─────────────────────────────────────
class SelectedFolderNotifier extends StateNotifier<AsyncValue<String?>> {
  final LocalFolderService _service;

  SelectedFolderNotifier(this._service) : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    try {
      final path = await _service.getSelectedFolderPath();
      if (path != null) {
        state = AsyncValue.data(path);
      } else {
        final defaultPath = await _service.getDefaultFolderPath();
        state = AsyncValue.data(defaultPath);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setFolderPath(String path) async {
    state = const AsyncValue.loading();
    try {
      await _service.setSelectedFolderPath(path);
      state = AsyncValue.data(path);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    init();
  }
}

final selectedFolderProvider =
    StateNotifierProvider<SelectedFolderNotifier, AsyncValue<String?>>((ref) {
  return SelectedFolderNotifier(ref.read(localFolderServiceProvider));
});

// ─────────────────────────────────────
// Feed content type filter
// ─────────────────────────────────────
enum FeedFilter { all, text }

final feedFilterProvider = StateProvider<FeedFilter>((ref) => FeedFilter.all);

// ─────────────────────────────────────
// Custom Feed toggles (legacy alias)
// ─────────────────────────────────────
final customFeedNotesProvider = StateProvider<bool>((ref) => true);

// ─────────────────────────────────────
// Feed items provider (Unified Vaults items)
// ─────────────────────────────────────
final feedItemsProvider = FutureProvider<List<FeedItem>>((ref) async {
  final folderService = ref.read(localFolderServiceProvider);
  final vaults = ref.watch(vaultsProvider);
  final folderState = ref.watch(selectedFolderProvider);

  List<FeedItem> allItems = [];

  if (!vaults.isCustomVaults) {
    // One Vault mode
    final rootPath = vaults.oneVaultPath ?? folderState.value;

    if (vaults.enableNotes) {
      final notes = await folderService.loadMarkdownItems(rootPath);
      allItems.addAll(notes);
    }
    if (vaults.enableImages) {
      final images = await folderService.loadImagesItems(rootPath);
      allItems.addAll(images);
    }
    if (vaults.enableVideos) {
      final videos = await folderService.loadVideosItems(rootPath);
      allItems.addAll(videos);
    }
    if (vaults.enableAudios) {
      final audios = await folderService.loadAudiosItems(rootPath);
      allItems.addAll(audios);
    }
  } else {
    // Custom Vaults mode
    if (vaults.enableNotes) {
      final notesPath =
          vaults.notesVaultPath ?? vaults.oneVaultPath ?? folderState.value;
      final notes = await folderService.loadMarkdownItems(notesPath);
      allItems.addAll(notes);
    }
    if (vaults.enableQuotes && vaults.quotesDirectoryPath != null) {
      final quotes =
          await folderService.loadQuotesItems(vaults.quotesDirectoryPath);
      allItems.addAll(quotes);
    }
    if (vaults.enableImages && vaults.imagesDirectoryPath != null) {
      final images =
          await folderService.loadImagesItems(vaults.imagesDirectoryPath);
      allItems.addAll(images);
    }
    if (vaults.enableVideos && vaults.videosDirectoryPath != null) {
      final videos =
          await folderService.loadVideosItems(vaults.videosDirectoryPath);
      allItems.addAll(videos);
    }
    if (vaults.enableAudios && vaults.audiosDirectoryPath != null) {
      final audios =
          await folderService.loadAudiosItems(vaults.audiosDirectoryPath);
      allItems.addAll(audios);
    }
    for (final customDir in vaults.customDirectories) {
      if (customDir.isEnabled &&
          customDir.path != null &&
          customDir.path!.isNotEmpty) {
        final customItems = await folderService.loadCustomItems(
          customDir.path!,
          customDir.type,
        );
        allItems.addAll(customItems);
      }
    }
  }

  // Deduplicate by path/id
  final seen = <String>{};
  allItems = allItems.where((item) => seen.add(item.id)).toList();

  // Apply feed filter if needed
  final filter = ref.watch(feedFilterProvider);
  if (filter == FeedFilter.text) {
    allItems = allItems.where((item) => item.type == ContentType.text).toList();
  }

  allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return allItems;
});

// ─────────────────────────────────────
// Bottom nav bar visibility
// ─────────────────────────────────────
final navBarVisibleProvider = StateProvider<bool>((ref) => true);

// ─────────────────────────────────────
// Current tab index
// ─────────────────────────────────────
final currentTabProvider = StateProvider<int>((ref) => 0);
