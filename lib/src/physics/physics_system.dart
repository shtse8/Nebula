import 'package:forge2d/forge2d.dart' as forge; // Import forge2d
import 'package:vector_math/vector_math.dart'; // Use base vector_math

import '../scene/component.dart'; // For Component base class check
import '../scene/entity.dart';
import '../scene/system.dart';
import '../scene/world.dart'
    as nebula; // Alias to avoid conflict with forge2d.World
import '../scene/components/transform_component.dart';
import 'components/rigidbody_component.dart';
import 'components/collider_component.dart'; // Needed for body creation logic later
import 'physics_world.dart'; // The wrapper class we just created

/// System responsible for managing the physics simulation using Forge2D.
///
/// This system initializes and steps the physics world, creates/destroys
/// physics bodies based on entity components, and synchronizes entity transforms
/// with physics body states.
class PhysicsSystem extends System {
  /// The wrapper around the Forge2D world.
  late final Forge2DPhysicsWorld physicsWorld;

  /// Creates a PhysicsSystem.
  ///
  /// Optionally accepts configuration for the physics world like gravity.
  PhysicsSystem({Vector2? gravity}) {
    // Vector2 is now base vector_math
    // Initialize the physics world wrapper
    physicsWorld = Forge2DPhysicsWorld(gravity: gravity);
  }

  @override
  void onAdded() {
    print("PhysicsSystem added.");
    // TODO: Implement logic to scan existing entities in the world
    // and create physics bodies for those with relevant components.
  }

  @override
  void update(Duration deltaTime) {
    // --- Force exit to prevent any physics logic due to build errors ---
    return;
    // 1. Step the physics simulation
    // physicsWorld.step(deltaTime); // Temporarily commented out due to build error

    // --- Temporarily commented out physics sync due to build error ---
    // // 2. Synchronize entity transforms with physics body states
    // // Query for entities that have both a RigidBody and a Transform
    // final entitiesToSync = world.queryEntities([
    //   RigidBodyComponent,
    //   TransformComponent,
    // ]);
    //
    // for (final entity in entitiesToSync) {
    //   final rigidBody = world.getComponent<RigidBodyComponent>(entity);
    //   final transform = world.getComponent<TransformComponent>(entity);
    //
    //   // Ensure components exist and the physics body has been created
    //   // Check isBodyInitialized AFTER confirming rigidBody is not null.
    //   if (rigidBody != null &&
    //       rigidBody.isBodyInitialized &&
    //       transform != null) {
    //     final forge.Body body = rigidBody.body; // Explicitly type body
    //
    //     // Update TransformComponent only for dynamic bodies moved by the simulation
    //     // Compare with forge.BodyType
    //     // Assuming the 'type' getter is correct in the newer forge2d version
    //     if (body.type == forge.BodyType.dynamic) { // <-- Build error here
    //       // Update position (only X and Y for 2D)
    //       transform.position.x = body.position.x;
    //       transform.position.y = body.position.y;
    //       // Keep Z position as it was (or manage separately if needed)
    //
    //       // Update rotation (only Z-axis for 2D)
    //       // Create a new quaternion representing rotation around Z
    //       // Use base vector_math.Vector3
    //       transform.rotation.setAxisAngle(Vector3(0, 0, 1), body.angle);
    //     }
    //   }
    // }
    // --- End temporarily commented out code ---

    // TODO: Implement entity/component addition/removal handling.
    // This typically involves listening to component added/removed events
    // or periodically checking for entities that need physics bodies created/destroyed.
  }

  @override
  void onRemoved() {
    print("PhysicsSystem removed.");
    // TODO: Implement cleanup logic, e.g., destroy all bodies in the physics world?
    // Or rely on entity removal logic to clean up individual bodies.
  }

  // --- Helper methods for entity/component lifecycle (to be implemented) ---

  /// Called when an entity with relevant components might need a physics body created.
  void _handleEntityPhysicsAddition(Entity entity) {
    final rigidBody = world.getComponent<RigidBodyComponent>(entity);
    final transform = world.getComponent<TransformComponent>(entity);
    // Get all collider components attached to the entity
    final colliders = world.getComponents<ColliderComponent>(
      entity,
    ); // Assumes World has getComponents

    if (rigidBody != null && transform != null && colliders.isNotEmpty) {
      // Check if body already exists (e.g., via rigidBody._body) to prevent duplicates
      // Use the public getter
      if (!rigidBody.isBodyInitialized) {
        physicsWorld.createBodyForEntity(
          entity,
          rigidBody,
          transform,
          colliders,
        );
      }
    }
  }

  /// Called when an entity with relevant components might need its physics body destroyed.
  void _handleEntityPhysicsRemoval(Entity entity) {
    final rigidBody = world.getComponent<RigidBodyComponent>(entity);
    // Check non-null first, then initialized state
    if (rigidBody != null && rigidBody.isBodyInitialized) {
      // Clear fixture references in colliders before destroying body
      final colliders = world.getComponents<ColliderComponent>(entity);
      for (final collider in colliders) {
        collider.clearFixtureInternal();
      }
      // rigidBody is guaranteed non-null here due to the check above
      physicsWorld.destroyBodyForEntity(entity, rigidBody);
    }
  }
}

// Temporary extension method on World - ideally World would provide this.
// This is needed for the helper methods above.
extension WorldExt on nebula.World {
  List<T> getComponents<T extends Component>(Entity entity) {
    // This is a placeholder implementation. A real implementation in World
    // would need access to its internal component storage.
    final component = getComponent<T>(entity);
    return component != null ? [component] : [];

    // OR, if World stores components differently:
    // return _componentsByType[T]?.values.where((c) => c.entity == entity).toList() ?? [];
  }
}
