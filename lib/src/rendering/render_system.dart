import 'dart:ui'; // For Duration, potentially Canvas later

import '../scene/system.dart';
import '../scene/world.dart' as nebula; // Alias needed
import '../scene/components/transform_component.dart'; // Import TransformComponent
import 'renderer.dart';
import 'components/sprite_component.dart'; // Import SpriteComponent
// TODO: Import MeshComponent when created

/// System responsible for rendering entities.
///
/// Queries the [World] for entities with renderable components (e.g., Transform
/// and Mesh/Sprite) and uses the provided [Renderer] to draw them to the screen.
class RenderSystem extends System {
  final Renderer renderer;

  /// Creates a RenderSystem that uses the given [renderer].
  RenderSystem(this.renderer);

  @override
  void onAdded() {
    // Optional: Initialize renderer or resources when added to the world.
    // Note: Renderer might need initialization elsewhere depending on Canvas availability.
    print("RenderSystem added.");
  }

  @override
  void update(Duration deltaTime) {
    // The 'update' phase for RenderSystem might involve:
    // - Culling entities that are off-screen.
    // - Sorting renderable entities (e.g., by Z-order, material).
    // - Preparing render batches.
    // For now, we don't have complex logic here.
    // print('RenderSystem update tick');
  }

  /// Performs the actual rendering onto the canvas.
  /// This method should be called from the Flutter paint cycle (e.g., CustomPainter).
  void render(Canvas canvas) {
    // 1. Prepare the renderer for the frame, providing the canvas
    renderer.beginFrame(canvas);
    renderer.clear(); // Example: Clear screen

    // 2. Query for entities with Transform and Sprite components
    final spriteEntities = world.queryEntities([
      TransformComponent,
      SpriteComponent,
    ]);

    // 3. Iterate and draw sprites
    for (final entity in spriteEntities) {
      final transform = world.getComponent<TransformComponent>(entity);
      final sprite = world.getComponent<SpriteComponent>(entity);

      // Ensure components and image exist and are enabled
      if (transform != null &&
          transform.isEnabled &&
          sprite != null &&
          sprite.isEnabled &&
          sprite.image != null) {
        final image = sprite.image!;
        final srcRect =
            sprite.sourceRect ??
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            );

        // Apply transformations using canvas save/restore
        canvas.save();

        // Translate to the entity's position
        canvas.translate(transform.position.x, transform.position.y);

        // Rotate around the Z axis (common for 2D)
        // Assumes transform.rotation primarily holds Z rotation
        canvas.rotate(transform.rotation.radians);

        // Scale - Note: scaling affects the draw size
        canvas.scale(transform.scale.x, transform.scale.y);

        // Calculate destination rect centered at the (now transformed) origin
        // Use the source rect size for drawing dimensions before scaling
        final double drawWidth = srcRect.width;
        final double drawHeight = srcRect.height;
        // Anchor point is center (0.5, 0.5)
        final double anchorX = drawWidth * 0.5;
        final double anchorY = drawHeight * 0.5;
        final dstRect = Rect.fromLTWH(
          -anchorX,
          -anchorY,
          drawWidth,
          drawHeight,
        );

        // Prepare paint object
        final paint = Paint();
        if (sprite.color != null) {
          paint.colorFilter = ColorFilter.mode(
            sprite.color!,
            BlendMode.modulate,
          );
        }
        if (sprite.blendMode != null) {
          paint.blendMode = sprite.blendMode!;
        }

        // Draw the sprite using the renderer
        renderer.drawSprite(image, dstRect, srcRect: srcRect, paint: paint);

        // Restore canvas to state before this entity's transforms
        canvas.restore();
      }
    }

    // TODO: Add similar loops for other renderable types (Meshes, Shapes, Text)

    // 4. Finalize the frame
    renderer.endFrame();
  }

  @override
  void onRemoved() {
    // Optional: Clean up renderer resources if managed here.
    print("RenderSystem removed.");
  }
}
