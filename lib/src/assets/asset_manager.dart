import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

/// Manages loading, caching, and accessing game assets like images.
class AssetManager {
  final Map<String, dynamic> _cache = {};

  /// Loads an asset of a specific type from a given path.
  ///
  /// Returns the loaded asset, potentially from cache.
  /// Throws an exception if loading fails.
  Future<T> load<T>(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path] as T;
    }

    // --- Image Loading ---
    if (T == ui.Image) {
      try {
        print('Loading image asset: $path'); // Debugging
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final image = frameInfo.image;
        _cache[path] = image;
        print(
          'Loaded image asset: $path (${image.width}x${image.height})',
        ); // Debugging
        return image as T;
      } catch (e) {
        print('Error loading image asset "$path": $e');
        throw Exception('Failed to load image asset: $path');
      }
    }
    // --- Add other asset type loading here (e.g., JSON, audio) ---
    // else if (T == YourJsonModel) { ... }

    // If type T is not handled, throw error
    throw UnimplementedError(
      'Asset loading for type $T at path "$path" not implemented.',
    );
  }

  /// Retrieves a previously loaded asset from the cache.
  /// Returns null if the asset is not cached.
  T? get<T>(String path) {
    return _cache[path] as T?;
  }

  /// Clears the asset cache.
  void clearCache() {
    // Dispose images before clearing cache
    _cache.forEach((key, asset) {
      if (asset is ui.Image) {
        asset.dispose();
      }
      // TODO: Dispose other disposable asset types
    });
    _cache.clear();
    print('Asset cache cleared.'); // Debugging
  }

  /// Unloads a specific asset from the cache.
  void unload(String path) {
    final asset = _cache.remove(path);
    if (asset != null) {
      if (asset is ui.Image) {
        asset.dispose();
        print('Unloaded and disposed image asset: $path'); // Debugging
      }
      // TODO: Dispose other disposable asset types
    }
  }
}

// Note: ui.Image is the primary type for loaded images.
// Other types like JSON models, audio data etc. would be defined elsewhere.
