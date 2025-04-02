import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math.dart'; // Use base vector_math

import 'collider_component.dart';

/// A collider component representing a rectangular shape (as a polygon).
class RectangleColliderComponent extends ColliderComponent {
  /// The width of the rectangle.
  double width;

  /// The height of the rectangle.
  double height;

  /// The local offset of the rectangle's center relative to the body's origin.
  Vector2 center;

  /// The local rotation of the rectangle relative to the body's rotation (in radians).
  double angle;

  /// Creates a RectangleColliderComponent centered at the body's origin by default.
  RectangleColliderComponent({
    required this.width,
    required this.height,
    Vector2? center, // This is now vector_math.Vector2
    this.angle = 0.0,
    double friction = 0.2,
    double restitution = 0.0,
    double density = 1.0,
    bool isSensor = false,
    forge.Filter? filterData,
    // Use vector_math.Vector2.zero()
  }) : center = center ?? Vector2.zero(),
       super(
         friction: friction,
         restitution: restitution,
         density: density,
         isSensor: isSensor,
         filterData: filterData,
       );

  @override
  forge.Shape createForgeShape() {
    final shape = forge.PolygonShape();
    // Forge2D's setAsBox takes half-width and half-height,
    // and optionally a center offset and angle relative to the body.
    shape.setAsBox(
      width / 2.0,
      height / 2.0,
      center, // Local center offset
      angle, // Local angle offset
    );
    return shape;
  }
}
