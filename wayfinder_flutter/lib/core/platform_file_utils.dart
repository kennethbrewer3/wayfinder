import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Safe metadata for logging and debugging — never reads [PlatformFile.path] on web.
Map<String, Object?> describePlatformFile(PlatformFile file) {
  return {
    'name': file.name,
    'size': file.size,
    'bytesLoaded': file.bytes?.length,
    'extension': file.extension,
    'platform': kIsWeb ? 'web' : 'io',
    if (!kIsWeb) 'path': file.path,
  };
}
