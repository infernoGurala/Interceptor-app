/// Cloudinary configuration.
/// Replace with your actual Cloudinary account credentials.
class CloudinaryConfig {
  static const String cloudName = 'dqzpd5jdd';
  static const String apiKey = '951423562179399';
  static const String apiSecret = 'YYzbChjhi07dIwnc9TNTUqQJNto';
  static const String uploadPreset = 'interceptor_uploads'; // unsigned preset

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  static String get fetchUrl =>
      'https://res.cloudinary.com/$cloudName/image/fetch/';
}
