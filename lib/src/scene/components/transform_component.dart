import 'package:vector_math/vector_math.dart'; // Use base vector_math

import '../component.dart';

/// Stores the position, rotation, and scale of an entity in 3D space.
class TransformComponent extends Component {
  /// Position in 3D space.
  final Vector3 position;

  /// Rotation represented as a quaternion.
  final Quaternion rotation;

  /// Scale in 3D space.
  final Vector3 scale;

  /// Creates a TransformComponent.
  ///
  /// Initializes with optional position, rotation, and scale.
  /// Defaults to origin (0,0,0), no rotation (identity quaternion),
  /// and unit scale (1,1,1).
  TransformComponent({Vector3? position, Quaternion? rotation, Vector3? scale})
    : position = position ?? Vector3.zero(),
      rotation = rotation ?? Quaternion.identity(),
      scale = scale ?? Vector3.all(1.0);

  // --- Convenience Methods (Optional) ---

  /// Returns the transformation matrix representing this transform.
  /// Combines translation, rotation, and scale.
  Matrix4 get matrix {
    // Create translation matrix
    final Matrix4 translationMatrix = Matrix4.translation(position);

    // Create rotation matrix from quaternion
    final Matrix4 rotationMatrix = Matrix4.compose(
      Vector3.zero(),
      rotation,
      Vector3.all(1.0),
    );
    // Alternative: Matrix4.fromQuaternion(rotation); but compose might be clearer

    // Create scale matrix
    final Matrix4 scaleMatrix = Matrix4.diagonal3(scale);

    // Combine: Scale -> Rotate -> Translate
    // Note: Matrix multiplication order is important (applied right-to-left)
    return translationMatrix * rotationMatrix * scaleMatrix;
  }

  /// Sets the transform from a Matrix4.
  /// Decomposes the matrix into position, rotation, and scale.
  /// Note: Decomposition can be complex and might lose precision or fail for
  /// certain matrices (e.g., shear). Use with caution.
  void setFromMatrix(Matrix4 matrix) {
    matrix.decompose(position, rotation, scale);
  }

  // TODO: Add methods for looking at a point, moving forward/right/up, etc.
}
