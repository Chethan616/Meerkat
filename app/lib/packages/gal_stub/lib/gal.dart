// Stub implementation of Gal for desktop platforms
// Gallery functionality is not available on Windows/macOS/Linux

library gal;

class Gal {
  /// Saves an image to the gallery (not supported on desktop)
  static Future<void> putImage(String path, {String? album}) async {
    // No-op on desktop - files are already saved to the destination directory
    return;
  }

  /// Saves a video to the gallery (not supported on desktop)
  static Future<void> putVideo(String path, {String? album}) async {
    // No-op on desktop - files are already saved to the destination directory
    return;
  }

  /// Checks if the app has access to the gallery (always false on desktop)
  static Future<bool> hasAccess({bool toAlbum = false}) async {
    return false;
  }

  /// Requests access to the gallery (always returns false on desktop)
  static Future<bool> requestAccess({bool toAlbum = false}) async {
    return false;
  }
}

/// Exception thrown by Gal operations
class GalException implements Exception {
  final GalExceptionType type;
  final String? message;

  GalException(this.type, [this.message]);

  @override
  String toString() => 'GalException: $type${message != null ? ' - $message' : ''}';
}

/// Types of exceptions that can be thrown by Gal
enum GalExceptionType {
  /// The file format is not supported by the gallery
  notSupportedFormat,

  /// Access to the gallery was denied
  accessDenied,

  /// Not enough space to save the file
  notEnoughSpace,

  /// The platform version is not supported
  notSupportedVersion,

  /// An unexpected error occurred
  unexpected,
}
