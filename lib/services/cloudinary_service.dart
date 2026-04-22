import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/cloudinary_config.dart';

/// Service for uploading media to Cloudinary via fetch URL.
class CloudinaryService {
  /// Upload a file to Cloudinary by providing a remote URL.
  /// Cloudinary fetches the file and stores it permanently.
  /// Returns the permanent Cloudinary URL.
  Future<String?> uploadFromUrl(String rawUrl, String resourceType) async {
    try {
      final uri = Uri.parse(CloudinaryConfig.uploadUrl);
      final response = await http.post(
        uri,
        body: {
          'file': rawUrl,
          'upload_preset': CloudinaryConfig.uploadPreset,
          'resource_type': resourceType, // 'image', 'video', or 'auto'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String?;
      } else {
        throw Exception(
          'Cloudinary upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a resource from Cloudinary by public ID.
  Future<bool> deleteResource(String publicId) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/destroy',
      );
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'api_key': CloudinaryConfig.apiKey,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
