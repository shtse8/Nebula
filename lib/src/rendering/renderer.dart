import 'dart:ui';
import 'dart:typed_data'; // For Float32List used in Vertices
import 'package:vector_math/vector_math.dart'; // For Matrix4
import 'camera.dart'; // Import Camera

/// The main rendering interface for the Nebula Engine.
///
/// This class abstracts the underlying Flutter rendering capabilities (`dart:ui`)
/// and provides methods for drawing 2D and 3D elements.
abstract class Renderer {
  // Initialization might happen elsewhere or be part of the constructor.

  /// Clears the render target.
  void clear();

  /// Begins a rendering frame using the provided canvas.
  /// The canvas should be ready for drawing (e.g., cleared or transformed).
  void beginFrame(Canvas canvas);

  /// Ends a rendering frame and presents it.
  void endFrame();

  /// Sets the camera for the current frame, defining view and projection.
  void setCamera(Camera camera);

  /// Renders a 2D sprite image.
  ///
  /// [image]: The image to draw.
  /// [dstRect]: The destination rectangle on the canvas where the image should be drawn.
  /// [srcRect]: The source rectangle within the image (for sprite sheets). Defaults to the full image.
  /// [paint]: Paint object containing color, blend mode, etc.
  void drawSprite(Image image, Rect dstRect, {Rect? srcRect, Paint? paint});

  /// Draws raw 2D vertices.
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint);

  /// Draws a rectangle.
  void drawRect(Rect rect, Paint paint);

  // TODO: Add methods for drawing other shapes, text, managing shaders, etc.
}

/// A concrete implementation of the Renderer (details TBD).
class NebulaRenderer implements Renderer {
  /// The canvas for the current frame. Only valid between beginFrame and endFrame.
  Canvas? _canvas;

  // No initialize method needed if canvas is provided per frame.
  // Constructor can be used for one-time setup if required.
  Camera? _currentCamera; // Store the current camera

  NebulaRenderer() {
    // TODO: One-time setup like loading default shaders/materials if any.
  }

  @override
  void clear() {
    // TODO: Implement clearing logic (e.g., drawing a background color).
    // Clearing is often done by the RenderSystem or the user before beginFrame.
    // Or provide a clear color parameter to beginFrame/clear.
    // For now, let's assume clearing happens before beginFrame or via a specific clear call.
    _canvas?.drawRect(
      Rect.largest,
      Paint()..color = const Color(0xFF000000),
    ); // Example clear
  }

  @override
  void beginFrame(Canvas canvas) {
    _canvas = canvas;
    // Save the initial state of the canvas provided by the painter.
    _canvas?.save();
    // TODO: Other frame setup (reset stats, etc.)
  }

  @override
  void endFrame() {
    // Restore to the initial state before returning control.
    _canvas?.restore();
    _canvas = null; // Invalidate canvas access after frame ends
    _currentCamera = null; // Clear camera reference at end of frame
    // TODO: Other frame finalization (log stats, etc.)
  }

  @override
  void setCamera(Camera camera) {
    _currentCamera = camera;
    // TODO: Potentially pre-calculate view-projection matrix here?
    // Or apply it directly to canvas transform in drawVertices/drawMesh?
    // For now, just store it. RenderSystem will need to access it.
  }

  @override
  void drawSprite(Image image, Rect dstRect, {Rect? srcRect, Paint? paint}) {
    if (_canvas == null) {
      print("Warning: drawSprite called outside of beginFrame/endFrame scope.");
      return;
    }
    // Use the full image if sourceRect is null
    final source =
        srcRect ??
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    // Use a default paint if none provided
    final paintToUse = paint ?? Paint();

    _canvas!.drawImageRect(image, source, dstRect, paintToUse);
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    if (_canvas == null) {
      print(
        "Warning: drawVertices called outside of beginFrame/endFrame scope.",
      );
      return;
    }
    // Simple 2D drawing without MVP transform for now
    _canvas!.drawVertices(vertices, blendMode, paint);
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    // Ensure canvas is valid before drawing
    if (_canvas == null) {
      print("Warning: drawRect called outside of beginFrame/endFrame scope.");
      return;
    }
    _canvas!.drawRect(rect, paint);
  }
}
