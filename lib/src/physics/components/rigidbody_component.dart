import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math.dart'; // Use base vector_math

import '../../scene/component.dart';

/// Defines the type of physics body.
enum BodyType {
  /// Zero mass, zero velocity, may be manually moved.
  static,

  /// Zero mass, non-zero velocity set by user, moved by solver.
  kinematic,

  /// Positive mass, non-zero velocity determined by forces, moved by solver.
  dynamic,
}

/// Component holding data for a 2D rigid body simulation using Forge2D.
///
/// This component stores the desired properties of the physics body.
/// The actual `forge.Body` instance is typically created and managed by the
/// `PhysicsSystem` and might be stored here after creation for easy access.
class RigidBodyComponent extends Component {
  /// The type of the physics body (static, kinematic, dynamic).
  BodyType bodyType;

  /// Initial linear velocity of the body.
  Vector2 linearVelocity;

  /// Initial angular velocity of the body (radians/second).
  double angularVelocity;

  /// Linear damping reduces linear velocity over time.
  double linearDamping;

  /// Angular damping reduces angular velocity over time.
  double angularDamping;

  /// Should this body be prevented from rotating?
  bool fixedRotation;

  /// Is this body initially allowed to sleep?
  bool allowSleep;

  /// Is this body initially awake?
  bool awake;

  /// Is this body treated like a bullet for continuous collision detection?
  bool bullet;

  /// A reference to the actual Forge2D body instance.
  /// This is typically set and managed by the PhysicsSystem after the body
  /// is added to the Forge2D world. It's nullable because it doesn't exist
  /// until the system processes it.
  forge.Body? _body;

  /// Creates a RigidBodyComponent.
  RigidBodyComponent({
    this.bodyType = BodyType.static,
    Vector2? linearVelocity, // This is now vector_math.Vector2
    this.angularVelocity = 0.0,
    this.linearDamping = 0.0,
    this.angularDamping = 0.0,
    this.fixedRotation = false,
    this.allowSleep = true,
    this.awake = true,
    this.bullet = false,
    // Use vector_math.Vector2.zero()
  }) : linearVelocity = linearVelocity ?? Vector2.zero();

  /// Gets the underlying Forge2D body. Throws if not yet created by PhysicsSystem.
  forge.Body get body {
    if (_body == null) {
      throw StateError(
        'Forge2D body has not been initialized by the PhysicsSystem yet.',
      );
    }
    return _body!;
  }

  /// Returns true if the underlying Forge2D body has been initialized by the PhysicsSystem.
  bool get isBodyInitialized => _body != null;

  /// Internal method used by PhysicsSystem to set the Forge2D body reference.
  /// Should not be called directly by users.
  void setBodyInternal(forge.Body body) {
    _body = body;
  }

  /// Internal method used by PhysicsSystem to clear the Forge2D body reference.
  void clearBodyInternal() {
    _body = null;
  }

  /// Converts the Nebula Engine BodyType enum to the Forge2D BodyType enum.
  forge.BodyType get forgeBodyType {
    switch (bodyType) {
      case BodyType.static:
        return forge.BodyType.static;
      case BodyType.kinematic:
        return forge.BodyType.kinematic;
      case BodyType.dynamic:
        return forge.BodyType.dynamic;
    }
  }
}
