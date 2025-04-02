import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math.dart'; // Use base vector_math

import 'collider_component.dart';

/// A collider component representing a circular shape.
class CircleColliderComponent extends ColliderComponent {
  /// The radius of the circle.
  double radius;

  /// The local offset of the circle's center relative to the body's origin.
  Vector2 offset;

  /// Creates a CircleColliderComponent.
  CircleColliderComponent({
    required this.radius,
    Vector2? offset, // This is now vector_math.Vector2
    double friction = 0.2,
    double restitution = 0.0,
    double density = 1.0,
    bool isSensor = false,
    forge.Filter? filterData,
    // Use vector_math.Vector2.zero()
  }) : offset = offset ?? Vector2.zero(),
       super(
         friction: friction,
         restitution: restitution,
         density: density,
         isSensor: isSensor,
         filterData: filterData,
       );

  @override
  forge.Shape createForgeShape() {
    final shape = forge.CircleShape();
    shape.radius = radius;
    shape.position.setFrom(offset); // Set the local offset
    return shape;
  }
}
