typedef TimestampBuilder = int Function();

class LessonMediaPathBuilder {
  LessonMediaPathBuilder({TimestampBuilder? timestampBuilder})
      : _nowMillis = timestampBuilder ?? _defaultTimestamp;

  final TimestampBuilder _nowMillis;

  String buildPath({
    required String courseId,
    required String lessonId,
    required String filename,
  }) {
    final safeName = _sanitizeFilename(filename);
    final ts = _nowMillis();
    return '$courseId/$lessonId/${ts}_$safeName';
  }

  String bucketFor({required bool isIntro}) {
    return isIntro ? 'public-media' : 'course-media';
  }

  String kindFromContentType(String contentType) {
    final lower = contentType.toLowerCase();
    if (lower.startsWith('image/')) return 'image';
    if (lower.startsWith('video/')) return 'video';
    if (lower.startsWith('audio/')) return 'audio';
    if (lower == 'application/pdf') return 'pdf';
    return 'other';
  }

  static int _defaultTimestamp() => DateTime.now().toUtc().millisecondsSinceEpoch;

  String _sanitizeFilename(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) return 'media.bin';
    final parts = trimmed.split('.');
    if (parts.length > 1) {
      final ext = parts.removeLast().toLowerCase();
      final base = parts
          .join('.')
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
      return '${base.isEmpty ? 'media' : base}.$ext';
    }
    final base = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
    return base.isEmpty ? 'media' : base;
  }
}
