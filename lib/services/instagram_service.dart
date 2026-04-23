import 'package:http/http.dart' as http;

/// Service for extracting direct Instagram video URLs from public post/reel pages.
class InstagramService {
  static const _browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  bool isInstagramReelOrPostUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || uri.host.isEmpty) return false;

    final host = uri.host.toLowerCase();
    if (!host.endsWith('instagram.com')) return false;

    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return false;

    return pathSegments.first == 'reel' || pathSegments.first == 'p';
  }

  Future<String> extractVideoUrl(String instagramUrl) async {
    final uri = Uri.tryParse(instagramUrl);
    if (uri == null || uri.host.isEmpty) {
      throw Exception('Invalid Instagram URL');
    }

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': _browserUserAgent,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch Instagram page (${_safeLogUrl(uri)}): ${response.statusCode}',
      );
    }

    final html = response.body;

    final extractedUrl = _extractFromMetaTag(html) ?? _extractFromScriptJson(html);

    if (extractedUrl == null || extractedUrl.isEmpty) {
      throw Exception(
        'Could not extract video URL from Instagram page: ${_safeLogUrl(uri)}',
      );
    }

    return extractedUrl;
  }

  /// Extracts an Open Graph video URL from HTML meta tags such as
  /// `og:video` and `og:video:secure_url`.
  String? _extractFromMetaTag(String html) {
    final regexes = <RegExp>[
      RegExp(
        r'<meta[^>]*property=["\']og:video(?::secure_url)?["\'][^>]*content=["\']([^"\']+)["\']',
        caseSensitive: false,
      ),
      RegExp(
        r'<meta[^>]*content=["\']([^"\']+)["\'][^>]*property=["\']og:video(?::secure_url)?["\']',
        caseSensitive: false,
      ),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(html);
      final content = match?.group(1);
      if (content != null && content.isNotEmpty) {
        return _normalizeExtractedUrl(content);
      }
    }

    return null;
  }

  /// Extracts an Instagram `video_url` value from JSON embedded in scripts.
  String? _extractFromScriptJson(String html) {
    final match = RegExp(
      r'"video_url":"(https?:(?:\\\\/\\\\/|//)[^"]+)"',
      caseSensitive: false,
    ).firstMatch(html);
    final value = match?.group(1);
    if (value == null || value.isEmpty) return null;
    return _normalizeExtractedUrl(value);
  }

  /// Normalizes encoded/escaped URL fragments returned from HTML or script JSON.
  String _normalizeExtractedUrl(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll(r'\/', '/')
        .replaceAll(r'\u0026', '&');
  }

  String _safeLogUrl(Uri uri) {
    return uri.replace(query: '', fragment: '').toString();
  }
}
