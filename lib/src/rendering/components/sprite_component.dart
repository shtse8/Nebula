import 'dart:ui'; // Import Rect, Color, BlendMode, Image etc.

import '../../scene/component.dart';

/// Component that holds data for rendering a sprite.
class SpriteComponent extends Component {
  /// The image to render for this sprite.
  /// This is typically loaded via the AssetManager.
  Image? image;

  /// Optional: Source rectangle within the image (for sprite sheets).
  Rect? sourceRect;

  /// Optional: Tint color to apply to the sprite.
  Color? color;

  /// Optional: Blend mode for rendering.
  BlendMode? blendMode;

  // TODO: Add fields for anchor point, flip, etc.

  /// Creates a SpriteComponent.
  ///
  /// Requires an [image] to be set (usually after loading).
  SpriteComponent({
    this.image,
    this.sourceRect,
    this.color, // Defaults to no tint
    this.blendMode, // Defaults to BlendMode.srcOver usually
  });
}
