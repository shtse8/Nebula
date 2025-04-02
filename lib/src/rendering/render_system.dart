import 'dart:ui'; // For Duration, potentially Canvas later

import '../scene/system.dart';
import 'package:vector_math/vector_math.dart'; // For Matrix4
import '../scene/world.dart' as nebula; // Alias needed
import '../scene/components/transform_component.dart'; // Import TransformComponent
import 'renderer.dart';
import 'camera.dart'; // Import Camera
import 'components/sprite_component.dart'; // Import SpriteComponent
import 'components/mesh_component.dart'; // Import MeshComponent

/// System responsible for rendering entities.
///
/// Queries the [World] for entities with renderable components (e.g., Transform
/// and Mesh/Sprite) and uses the provided [Renderer] to draw them to the screen.
class RenderSystem extends System {
  final Renderer renderer;
  late final Camera camera; // Add a camera reference

  /// Creates a RenderSystem that uses the given [renderer].
  /// Creates a RenderSystem that uses the given [renderer] and [camera].
  RenderSystem(this.renderer, this.camera);

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
    renderer.setCamera(camera); // Set the camera for the frame
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

        // Calculate destination rect as a unit square centered at the origin.
        // The canvas scale transform will handle the actual sizing based on transform.scale
        // and potentially a base size defined in SpriteComponent or elsewhere.
        // For now, assume scale directly controls pixel size relative to source.
        const double anchorX = 0.5; // Centered anchor
        const double anchorY = 0.5;
        final dstRect = Rect.fromLTWH(
          -anchorX, // -0.5
          -anchorY, // -0.5
          1.0, // Width = 1 unit
          1.0, // Height = 1 unit
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

    // --- Mesh Rendering ---
    final meshEntities = world.queryEntities([
      TransformComponent,
      MeshComponent,
    ]);

    for (final entity in meshEntities) {
      final transform = world.getComponent<TransformComponent>(entity);
      final mesh = world.getComponent<MeshComponent>(entity);

      if (transform != null &&
          transform.isEnabled &&
          mesh != null &&
          mesh.isEnabled &&
          mesh.verticesObject != null) {
        final vertices = mesh.verticesObject!;
        // TODO: Apply material properties (color, shader, texture) to Paint
        final paint =
            Paint()
              ..color = const Color(0xFF00FF00); // Default green for meshes

        // Apply transformations using canvas save/restore
        canvas.save();
        canvas.translate(transform.position.x, transform.position.y);
        canvas.rotate(transform.rotation.radians);
        canvas.scale(transform.scale.x, transform.scale.y);

        // Draw the vertices using the renderer
        // Note: drawVertices doesn't inherently handle 3D projection or model matrix.
        // The renderer's implementation of drawVertices would need to apply
        // the camera's viewProjection matrix and this entity's model matrix (from transform).
        // For now, this will draw the 2D offsets defined in MeshComponent, transformed.
        // Pass BlendMode (e.g., srcOver) instead of VertexMode
        // Pass the modelMatrix to the renderer
        renderer.drawVertices(vertices, BlendMode.srcOver, paint);

        canvas.restore(); // Restore canvas state
      }
    }
    // --- End Mesh Rendering ---

    // TODO: Add loops for Shapes, Text etc.

    // 4. Finalize the frame
    renderer.endFrame();
  }

  @override
  void onRemoved() {
    // Optional: Clean up renderer resources if managed here.
    print("RenderSystem removed.");
  }
}
