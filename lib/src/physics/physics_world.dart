import 'package:forge2d/forge2d.dart' as forge;
import 'package:vector_math/vector_math.dart'; // Use base vector_math
import 'dart:math' as math; // Import dart:math for atan2

import '../scene/entity.dart';
import 'components/collider_component.dart';
import 'components/rigidbody_component.dart';
import '../scene/components/transform_component.dart'; // Needed for initial position

/// Manages the Forge2D physics simulation world.
///
/// This class acts as a wrapper around the `forge2d.World` instance and
/// provides methods for creating, destroying, and stepping the simulation.
/// It's typically managed by the `PhysicsSystem`.
class Forge2DPhysicsWorld {
  /// The underlying Forge2D world instance.
  late final forge.World _world;

  /// Default gravity vector (can be overridden during initialization).
  static final Vector2 defaultGravity = Vector2(0, -9.8);

  /// Default velocity iterations for the physics solver.
  final int velocityIterations;

  /// Default position iterations for the physics solver.
  final int positionIterations;

  /// A map to quickly find the Nebula Entity ID associated with a Forge2D Body.
  final Map<forge.Body, Entity> _bodyToEntityMap = {};

  /// Creates and initializes the Forge2D physics world.
  Forge2DPhysicsWorld({
    Vector2? gravity,
    this.velocityIterations = 8, // Common default values
    this.positionIterations = 3, // Common default values
  }) {
    final forgeGravity = forge.Vector2(
      (gravity ?? defaultGravity).x,
      (gravity ?? defaultGravity).y,
    );
    _world = forge.World(forgeGravity);
    print(
      'Forge2DPhysicsWorld initialized with gravity: $forgeGravity, vIter: $velocityIterations, pIter: $positionIterations',
    );
  }

  /// Steps the physics simulation forward by the given time delta.
  void step(Duration deltaTime) {
    // Forge2D expects time in seconds.
    final dt = deltaTime.inMilliseconds / 1000.0;
    // Avoid large steps or zero steps which can cause instability.
    if (dt <= 0) return;
    // Clamp dt? Consider a maximum step time if needed.

    // _world.step(dt, velocityIterations, positionIterations); // Still causes build error
    _world.stepDt(dt); // Use stepDt for now
  }

  /// Creates a Forge2D body and its fixtures based on an entity's components.
  ///
  /// This is typically called by the PhysicsSystem when an entity with physics
  /// components is added or needs its physics representation created.
  ///
  /// Requires the entity to have at least a [RigidBodyComponent] and a
  /// [TransformComponent]. [ColliderComponent]s are needed to give it shape.
  void createBodyForEntity(
    Entity entity,
    RigidBodyComponent rigidBody,
    TransformComponent transform,
    List<ColliderComponent> colliders,
  ) {
    if (_bodyToEntityMap.containsValue(entity)) {
      print(
        'Warning: Attempted to create body for entity $entity which already has one.',
      );
      return; // Avoid creating duplicate bodies
    }

    final bodyDef = forge.BodyDef();
    bodyDef.type = rigidBody.forgeBodyType;
    bodyDef.position = forge.Vector2(
      transform.position.x,
      transform.position.y,
    );
    // Note: Forge2D uses radians for angles. TransformComponent uses Quaternion.
    // Get the rotation angle around the Z axis from the quaternion.
    // Assumes the quaternion represents primarily 2D rotation.
    // 'radians' gives the angle of rotation.
    bodyDef.angle = transform.rotation.radians;

    bodyDef.linearVelocity = forge.Vector2(
      rigidBody.linearVelocity.x,
      rigidBody.linearVelocity.y,
    );
    bodyDef.angularVelocity = rigidBody.angularVelocity;
    bodyDef.linearDamping = rigidBody.linearDamping;
    bodyDef.angularDamping = rigidBody.angularDamping;
    bodyDef.fixedRotation = rigidBody.fixedRotation;
    bodyDef.allowSleep = rigidBody.allowSleep;
    bodyDef.isAwake = rigidBody.awake; // Use isAwake field name
    bodyDef.bullet = rigidBody.bullet;
    bodyDef.userData = entity; // Store Nebula entity ID in Forge2D body

    final body = _world.createBody(bodyDef);
    _bodyToEntityMap[body] = entity; // Map Forge2D body back to Nebula entity
    rigidBody.setBodyInternal(body); // Store reference in component

    // Create fixtures for each collider
    for (final collider in colliders) {
      final shape = collider.createForgeShape();
      final fixtureDef = collider.createFixtureDef(shape);
      fixtureDef.userData =
          collider; // Store collider component reference in fixture
      final fixture = body.createFixture(fixtureDef);
      collider.setFixtureInternal(fixture); // Store reference in component
    }
    print('Created Forge2D body for entity $entity');
  }

  /// Destroys the Forge2D body associated with the given Nebula entity.
  ///
  /// This is typically called by the PhysicsSystem when an entity with physics
  /// components is removed or needs its physics representation destroyed.
  void destroyBodyForEntity(Entity entity, RigidBodyComponent rigidBody) {
    final body = rigidBody.body; // Get the Forge2D body via the component
    if (body != null && _bodyToEntityMap.containsKey(body)) {
      // Clear references in components first
      rigidBody.clearBodyInternal();
      // TODO: Need a way to get colliders associated with this entity/body to clear their fixture refs
      // Maybe store colliders list in RigidBodyComponent or query the world?
      // For now, assume PhysicsSystem handles clearing collider fixture refs before calling this.

      _world.destroyBody(body);
      _bodyToEntityMap.remove(body);
      print('Destroyed Forge2D body for entity $entity');
    } else {
      print(
        'Warning: Attempted to destroy body for entity $entity, but no matching body found or already destroyed.',
      );
    }
  }

  /// Gets the Nebula Entity ID associated with a Forge2D Body.
  /// Returns nullEntity if the body is not tracked.
  Entity getEntityForBody(forge.Body body) {
    return _bodyToEntityMap[body] ?? nullEntity;
  }

  /// Provides direct access to the underlying Forge2D world instance.
  /// Use with caution, prefer interacting via PhysicsSystem and components.
  forge.World get forgeWorld => _world;

  // TODO: Implement query methods (raycasting, shape queries) by wrapping Forge2D world queries.
}

// Removed incorrect eulerAngles extension. Use quaternion.radians for Z-axis angle.
