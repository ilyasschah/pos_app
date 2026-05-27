import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Writes product images to disk and returns the absolute local path so we
/// can store *paths* in SQLite instead of binary blobs (plan constraint).
///
/// Accepts either a remote URL (`http://...` / `https://...`) or a raw base64
/// string — the existing C# `/Products/GetAll` endpoint currently serves
/// base64-encoded bytes, but the helper is URL-ready for when the backend
/// switches to a CDN.
class ImageSyncHelper {
  ImageSyncHelper(this._dio);

  final Dio _dio;

  static const _folderName = 'product_images';

  /// Returns the absolute path of the saved file, or `null` if the source
  /// was empty/invalid or the download failed. Errors are swallowed —
  /// a missing image must never break the master-data pull.
  Future<String?> downloadAndSaveImage(
    String? imageUrlOrBase64,
    int productId,
  ) async {
    if (imageUrlOrBase64 == null || imageUrlOrBase64.isEmpty) return null;

    try {
      final bytes = await _resolveBytes(imageUrlOrBase64);
      if (bytes == null || bytes.isEmpty) return null;

      final dir = await _ensureImagesDir();
      final file = File(p.join(dir.path, '$productId.jpg'));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteImage(int productId) async {
    try {
      final dir = await _ensureImagesDir();
      final file = File(p.join(dir.path, '$productId.jpg'));
      if (await file.exists()) await file.delete();
    } catch (_) {
      // best-effort cleanup; ignore
    }
  }

  /// Use from the UI when binding a Drift row to an Image widget — returns
  /// `null` if the file is gone (app reinstall, cache wipe, etc.) so the
  /// caller can fall back to a placeholder.
  String? resolveExisting(String? localPath) {
    if (localPath == null || localPath.isEmpty) return null;
    return File(localPath).existsSync() ? localPath : null;
  }

  Future<Uint8List?> _resolveBytes(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      final res = await _dio.get<List<int>>(
        source,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      return data == null ? null : Uint8List.fromList(data);
    }
    // Treat anything else as base64. Strip a possible data-URI prefix.
    final cleaned = source.contains(',') ? source.split(',').last : source;
    return base64Decode(cleaned);
  }

  Future<Directory> _ensureImagesDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _folderName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
