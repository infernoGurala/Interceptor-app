import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_directory.dart';

export '../models/custom_directory.dart';

/// State holding configuration for One Vault vs Custom Vaults and Revise feed toggles.
class VaultsState {
  final bool isCustomVaults;
  final String? oneVaultPath;
  final String? notesVaultPath;
  final String? quotesDirectoryPath;
  final String? imagesDirectoryPath;
  final String? videosDirectoryPath;
  final String? audiosDirectoryPath;
  final List<CustomDirectory> customDirectories;

  // Revise feed standard toggles
  final bool enableNotes;
  final bool enableQuotes;
  final bool enableImages;
  final bool enableVideos;
  final bool enableAudios;

  const VaultsState({
    this.isCustomVaults = false,
    this.oneVaultPath,
    this.notesVaultPath,
    this.quotesDirectoryPath,
    this.imagesDirectoryPath,
    this.videosDirectoryPath,
    this.audiosDirectoryPath,
    this.customDirectories = const [],
    this.enableNotes = true,
    this.enableQuotes = true,
    this.enableImages = true,
    this.enableVideos = true,
    this.enableAudios = true,
  });

  // Backward compatibility getters
  String get customDirectoryName =>
      customDirectories.isNotEmpty ? customDirectories.first.name : 'Custom Vault';
  String? get customDirectoryPath =>
      customDirectories.isNotEmpty ? customDirectories.first.path : null;
  bool get enableCustom =>
      customDirectories.isNotEmpty ? customDirectories.first.isEnabled : true;

  VaultsState copyWith({
    bool? isCustomVaults,
    String? oneVaultPath,
    String? notesVaultPath,
    String? quotesDirectoryPath,
    String? imagesDirectoryPath,
    String? videosDirectoryPath,
    String? audiosDirectoryPath,
    List<CustomDirectory>? customDirectories,
    bool? enableNotes,
    bool? enableQuotes,
    bool? enableImages,
    bool? enableVideos,
    bool? enableAudios,
  }) {
    return VaultsState(
      isCustomVaults: isCustomVaults ?? this.isCustomVaults,
      oneVaultPath: oneVaultPath ?? this.oneVaultPath,
      notesVaultPath: notesVaultPath ?? this.notesVaultPath,
      quotesDirectoryPath: quotesDirectoryPath ?? this.quotesDirectoryPath,
      imagesDirectoryPath: imagesDirectoryPath ?? this.imagesDirectoryPath,
      videosDirectoryPath: videosDirectoryPath ?? this.videosDirectoryPath,
      audiosDirectoryPath: audiosDirectoryPath ?? this.audiosDirectoryPath,
      customDirectories: customDirectories ?? this.customDirectories,
      enableNotes: enableNotes ?? this.enableNotes,
      enableQuotes: enableQuotes ?? this.enableQuotes,
      enableImages: enableImages ?? this.enableImages,
      enableVideos: enableVideos ?? this.enableVideos,
      enableAudios: enableAudios ?? this.enableAudios,
    );
  }
}

class VaultsNotifier extends StateNotifier<VaultsState> {
  VaultsNotifier() : super(const VaultsState()) {
    _loadFromPrefs();
  }

  static const _keyIsCustomVaults = 'vault_is_custom_vaults';
  static const _keyOneVaultPath = 'selected_markdown_folder_path';
  static const _keyNotesVaultPath = 'vault_notes_path';
  static const _keyQuotesPath = 'vault_quotes_path';
  static const _keyImagesPath = 'vault_images_path';
  static const _keyVideosPath = 'vault_videos_path';
  static const _keyAudiosPath = 'vault_audios_path';
  static const _keyCustomDirectories = 'vault_custom_directories_json';

  // Legacy keys for migration
  static const _keyCustomPath = 'vault_custom_path';
  static const _keyCustomName = 'vault_custom_name';
  static const _keyEnableCustom = 'revise_enable_custom';

  static const _keyEnableNotes = 'revise_enable_notes';
  static const _keyEnableQuotes = 'revise_enable_quotes';
  static const _keyEnableImages = 'revise_enable_images';
  static const _keyEnableVideos = 'revise_enable_videos';
  static const _keyEnableAudios = 'revise_enable_audios';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final customDirsJson = prefs.getString(_keyCustomDirectories);
    List<CustomDirectory> customDirs = [];
    if (customDirsJson != null && customDirsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(customDirsJson) as List;
        customDirs = decoded
            .map((e) => CustomDirectory.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Migration / default: ensure at least one custom directory if none existed
    if (customDirs.isEmpty) {
      final legacyPath = prefs.getString(_keyCustomPath);
      final legacyName = prefs.getString(_keyCustomName) ?? 'Custom Vault';
      final legacyEnabled = prefs.getBool(_keyEnableCustom) ?? true;
      customDirs.add(
        CustomDirectory(
          id: 'custom_1',
          name: legacyName,
          path: legacyPath,
          type: DirectoryType.mixed,
          isEnabled: legacyEnabled,
        ),
      );
    }

    state = VaultsState(
      isCustomVaults: prefs.getBool(_keyIsCustomVaults) ?? false,
      oneVaultPath: prefs.getString(_keyOneVaultPath),
      notesVaultPath: prefs.getString(_keyNotesVaultPath),
      quotesDirectoryPath: prefs.getString(_keyQuotesPath),
      imagesDirectoryPath: prefs.getString(_keyImagesPath),
      videosDirectoryPath: prefs.getString(_keyVideosPath),
      audiosDirectoryPath: prefs.getString(_keyAudiosPath),
      customDirectories: customDirs,
      enableNotes: prefs.getBool(_keyEnableNotes) ?? true,
      enableQuotes: prefs.getBool(_keyEnableQuotes) ?? true,
      enableImages: prefs.getBool(_keyEnableImages) ?? true,
      enableVideos: prefs.getBool(_keyEnableVideos) ?? true,
      enableAudios: prefs.getBool(_keyEnableAudios) ?? true,
    );
  }

  Future<void> _saveCustomDirectories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.customDirectories.map((d) => d.toMap()).toList());
    await prefs.setString(_keyCustomDirectories, jsonStr);
  }

  Future<void> toggleCustomVaults(bool value) async {
    state = state.copyWith(isCustomVaults: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCustomVaults, value);
  }

  Future<void> setOneVaultPath(String path) async {
    state = state.copyWith(oneVaultPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOneVaultPath, path);
  }

  Future<void> setNotesVaultPath(String path) async {
    state = state.copyWith(notesVaultPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotesVaultPath, path);
  }

  Future<void> setQuotesDirectoryPath(String path) async {
    state = state.copyWith(quotesDirectoryPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyQuotesPath, path);
  }

  Future<void> setImagesDirectoryPath(String path) async {
    state = state.copyWith(imagesDirectoryPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyImagesPath, path);
  }

  Future<void> setVideosDirectoryPath(String path) async {
    state = state.copyWith(videosDirectoryPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVideosPath, path);
  }

  Future<void> setAudiosDirectoryPath(String path) async {
    state = state.copyWith(audiosDirectoryPath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAudiosPath, path);
  }

  // ─────────────────────────────────────
  // Custom Directories (Infinite amount)
  // ─────────────────────────────────────
  Future<void> addCustomDirectory({
    String? name,
    String? path,
    DirectoryType type = DirectoryType.mixed,
  }) async {
    final newDir = CustomDirectory(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : 'Custom Vault ${state.customDirectories.length + 1}',
      path: path,
      type: type,
      isEnabled: true,
    );
    state = state.copyWith(
      customDirectories: [...state.customDirectories, newDir],
    );
    await _saveCustomDirectories();
  }

  Future<void> removeCustomDirectory(String id) async {
    state = state.copyWith(
      customDirectories: state.customDirectories.where((d) => d.id != id).toList(),
    );
    await _saveCustomDirectories();
  }

  Future<void> updateCustomDirectoryName(String id, String newName) async {
    final clean = newName.trim().isEmpty ? 'Custom Vault' : newName.trim();
    state = state.copyWith(
      customDirectories: state.customDirectories.map((d) {
        if (d.id == id) {
          return d.copyWith(name: clean);
        }
        return d;
      }).toList(),
    );
    await _saveCustomDirectories();
  }

  Future<void> updateCustomDirectoryPath(String id, String newPath) async {
    state = state.copyWith(
      customDirectories: state.customDirectories.map((d) {
        if (d.id == id) {
          return d.copyWith(path: newPath);
        }
        return d;
      }).toList(),
    );
    await _saveCustomDirectories();
  }

  Future<void> updateCustomDirectoryType(String id, DirectoryType type) async {
    state = state.copyWith(
      customDirectories: state.customDirectories.map((d) {
        if (d.id == id) {
          return d.copyWith(type: type);
        }
        return d;
      }).toList(),
    );
    await _saveCustomDirectories();
  }

  Future<void> toggleCustomDirectory(String id, bool isEnabled) async {
    state = state.copyWith(
      customDirectories: state.customDirectories.map((d) {
        if (d.id == id) {
          return d.copyWith(isEnabled: isEnabled);
        }
        return d;
      }).toList(),
    );
    await _saveCustomDirectories();
  }

  // Legacy helper aliases
  Future<void> setCustomDirectoryName(String newName) async {
    if (state.customDirectories.isNotEmpty) {
      await updateCustomDirectoryName(state.customDirectories.first.id, newName);
    } else {
      await addCustomDirectory(name: newName);
    }
  }

  Future<void> setCustomDirectoryPath(String newPath) async {
    if (state.customDirectories.isNotEmpty) {
      await updateCustomDirectoryPath(state.customDirectories.first.id, newPath);
    } else {
      await addCustomDirectory(path: newPath);
    }
  }

  Future<void> toggleCustom(bool value) async {
    if (state.customDirectories.isNotEmpty) {
      await toggleCustomDirectory(state.customDirectories.first.id, value);
    }
  }

  // ─────────────────────────────────────
  // Standard Revise feed toggles
  // ─────────────────────────────────────
  Future<void> toggleNotes(bool value) async {
    state = state.copyWith(enableNotes: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableNotes, value);
  }

  Future<void> toggleQuotes(bool value) async {
    state = state.copyWith(enableQuotes: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableQuotes, value);
  }

  Future<void> toggleImages(bool value) async {
    state = state.copyWith(enableImages: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableImages, value);
  }

  Future<void> toggleVideos(bool value) async {
    state = state.copyWith(enableVideos: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableVideos, value);
  }

  Future<void> toggleAudios(bool value) async {
    state = state.copyWith(enableAudios: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableAudios, value);
  }
}

final vaultsProvider = StateNotifierProvider<VaultsNotifier, VaultsState>(
  (ref) => VaultsNotifier(),
);
