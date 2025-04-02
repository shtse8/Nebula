import 'package:vector_math/vector_math.dart'; // Use base vector_math

/// Represents a camera in the 3D scene.
///
/// Defines the viewpoint and projection used for rendering.
class Camera {
  /// The position of the camera in world space.
  Vector3 position = Vector3.zero();

  /// The point the camera is looking at.
  Vector3 target = Vector3(0.0, 0.0, -1.0); // Look along negative Z by default

  /// The "up" direction for the camera.
  Vector3 up = Vector3(0.0, 1.0, 0.0); // Y-up by default

  /// Field of View in radians (for perspective projection).
  double fieldOfViewYRadians = radians(60.0); // Example: 60 degrees FoV

  /// Aspect ratio (width / height) of the viewport.
  double aspectRatio = 16.0 / 9.0; // Default aspect ratio

  /// Near clipping plane distance.
  double nearPlane = 0.1;

  /// Far clipping plane distance.
  double farPlane = 1000.0;

  // --- Calculated Matrices ---

  /// The view matrix transforms world coordinates to view (camera) coordinates.
  Matrix4 get viewMatrix {
    // Use lookAt function to create the view matrix
    return makeViewMatrix(position, target, up);
  }

  /// The projection matrix transforms view coordinates to clip coordinates.
  /// This example uses a perspective projection.
  Matrix4 get projectionMatrix {
    // Use perspective function to create the projection matrix
    return makePerspectiveMatrix(
      fieldOfViewYRadians,
      aspectRatio,
      nearPlane,
      farPlane,
    );
  }

  /// Combined view and projection matrix.
  Matrix4 get viewProjectionMatrix {
    return projectionMatrix * viewMatrix;
  }

  // TODO: Add methods to control camera movement (pan, zoom, orbit)
  // TODO: Add support for orthographic projection
}
