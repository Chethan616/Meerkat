// Stub for Gal on desktop platforms where gallery functionality isn't available
class Gal {
  static Future<void> putImage(String path) async {
    throw UnsupportedError('Gallery functionality not available on desktop platforms');
  }

  static Future<void> putVideo(String path) async {
    throw UnsupportedError('Gallery functionality not available on desktop platforms');
  }
}

class GalException implements Exception {
  final GalExceptionType type;
  final String? message;

  GalException(this.type, [this.message]);

  @override
  String toString() => 'GalException: $type ${message ?? ''}';
}

enum GalExceptionType {
  notSupportedFormat,
  accessDenied,
  notEnoughSpace,
  notSupportedVersion,
  unexpected,
}
