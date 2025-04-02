import 'package:forge2d/forge2d.dart' as forge;

import '../../scene/component.dart';
import 'rigidbody_component.dart'; // Needed to potentially access body

/// Base class for components that define collision shapes for a [RigidBodyComponent].
///
/// An entity with physics simulation typically needs at least one RigidBodyComponent
/// and one or more ColliderComponents attached.
abstract class ColliderComponent extends Component {
  /// The friction coefficient, usually in the range [0,1].
  double friction;

  /// The restitution (elasticity/bounciness), usually in the range [0,1].
  double restitution;

  /// The density, usually in kg/m^2.
  double density;

  /// Whether this collider is a sensor. Sensors detect collisions but don't
  /// generate collision responses (objects pass through them).
  bool isSensor;

  /// Collision filtering data. Allows controlling which fixtures collide with each other.
  forge.Filter filterData;

  /// A reference to the actual Forge2D fixture created from this component.
  /// Managed by the PhysicsSystem. Null until created.
  forge.Fixture? _fixture;

  ColliderComponent({
    this.friction = 0.2,
    this.restitution = 0.0,
    this.density = 1.0, // Default density for dynamic bodies
    this.isSensor = false,
    forge.Filter? filterData,
  }) : filterData =
           filterData ?? forge.Filter(); // Use default filter if none provided

  /// Abstract method for subclasses to create the specific Forge2D shape.
  forge.Shape createForgeShape();

  /// Creates the Forge2D FixtureDef based on this component's properties
  /// and the provided shape. Called by the PhysicsSystem.
  forge.FixtureDef createFixtureDef(forge.Shape shape) {
    return forge.FixtureDef(
      shape,
      friction: friction,
      restitution: restitution,
      density: density,
      isSensor: isSensor,
      filter: filterData,
    );
  }

  /// Gets the underlying Forge2D fixture. Throws if not yet created by PhysicsSystem.
  forge.Fixture get fixture {
    if (_fixture == null) {
      throw StateError(
        'Forge2D fixture has not been initialized by the PhysicsSystem yet.',
      );
    }
    return _fixture!;
  }

  /// Internal method used by PhysicsSystem to set the Forge2D fixture reference.
  void setFixtureInternal(forge.Fixture fixture) {
    _fixture = fixture;
  }

  /// Internal method used by PhysicsSystem to clear the Forge2D fixture reference.
  void clearFixtureInternal() {
    _fixture = null;
  }
}
