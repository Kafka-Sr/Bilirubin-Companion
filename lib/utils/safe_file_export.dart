import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves a safe output [File] within the app's documents directory.
///
/// [filename] must not be empty and must not contain path separators or
/// traversal sequences. Throws [ArgumentError] if the resolved path escapes
/// the documents directory.
Future<File> safeExportFile(String filename) async {
  if (filename.isEmpty) throw ArgumentError('Filename must not be empty.');

  // Strip any directory components from the filename to prevent traversal.
  final basename = p.basename(filename);
  if (basename.isEmpty || basename == '.' || basename == '..') {
    throw ArgumentError('Invalid filename: $filename');
  }

  final docsDir = await getApplicationDocumentsDirectory();
  final resolved = p.normalize(p.join(docsDir.path, basename));

  // Verify the resolved path is still inside the docs directory.
  if (!resolved.startsWith(p.normalize(docsDir.path))) {
    throw ArgumentError('Path traversal detected in filename: $filename');
  }

  return File(resolved);
}

/// Returns a sanitised filename safe for use in [safeExportFile].
///
/// Replaces characters that are illegal on common filesystems with underscores.
String sanitiseFilename(String raw) {
  return raw
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll('..', '_');
}
