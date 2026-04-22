import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/cobalt_config.dart';

/// Service for extracting raw media URLs from platform links using the Cobalt API.
class CobaltService {
  /// Send a platform link (Instagram, YouTube, etc.) to Cobalt and get
  /// back a raw downloadable media URL.
  Future<CobaltResult> extractMediaUrl(String platformLink) async {
    try {
      final uri = Uri.parse(CobaltConfig.apiEndpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'url': platformLink,
          'vCodec': 'h264',
          'vQuality': '720',
          'aFormat': 'mp3',
          'isAudioOnly': false,
          'isNoTTWatermark': true,
          'isTTFullAudio': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String?;

        if (status == 'stream' || status == 'redirect') {
          return CobaltResult(
            success: true,
            url: data['url'] as String,
            isStream: status == 'stream',
          );
        } else if (status == 'picker') {
          // Multiple options — return the first one
          final picker = data['picker'] as List;
          if (picker.isNotEmpty) {
            return CobaltResult(
              success: true,
              url: picker.first['url'] as String,
              isStream: false,
            );
          }
        }

        return CobaltResult(
          success: false,
          error: data['text'] as String? ?? 'Unknown error from Cobalt',
        );
      } else {
        return CobaltResult(
          success: false,
          error: 'Cobalt API returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return CobaltResult(success: false, error: e.toString());
    }
  }
}

/// Result from a Cobalt API call.
class CobaltResult {
  final bool success;
  final String? url;
  final String? error;
  final bool isStream;

  const CobaltResult({
    required this.success,
    this.url,
    this.error,
    this.isStream = false,
  });
}
