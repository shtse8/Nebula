import 'package:flutter/services.dart'; // For LogicalKeyboardKey
import 'package:nebula_engine/nebula_engine.dart';
import 'package:vector_math/vector_math.dart'; // For Vector3

/// A simple system to move an entity using WASD keys.
class PlayerControlSystem extends System {
  late final InputManager inputManager;
  final double moveSpeed = 100.0; // Pixels per second

  @override
  void onAdded() {
    // Get the InputManager instance from the InputSystem added to the world
    final inputSystem = world.getSystem<InputSystem>();
    if (inputSystem == null) {
      throw StateError(
        'InputSystem not found in the world. Add it before PlayerControlSystem.',
      );
    }
    inputManager = inputSystem.inputManager;
  }

  @override
  void update(Duration deltaTime) {
    // print("PlayerControlSystem update"); // Check if system runs
    // Find entities with a TransformComponent (we'll just control the first one found)
    final controllableEntities = world.queryEntities([TransformComponent]);
    if (controllableEntities.isEmpty) {
      return; // No entities to control
    }

    final entityToControl = controllableEntities.first;
    final transform = world.getComponent<TransformComponent>(entityToControl);

    if (transform == null) {
      return; // Should not happen if queryEntities works correctly
    }

    // Calculate movement based on input and delta time
    final double deltaSeconds = deltaTime.inMilliseconds / 1000.0;
    final double moveAmount = moveSpeed * deltaSeconds;
    Vector3 moveDelta = Vector3.zero();

    if (inputManager.isKeyPressed(LogicalKeyboardKey.keyW)) {
      moveDelta.y -= moveAmount;
    }
    if (inputManager.isKeyPressed(LogicalKeyboardKey.keyS)) {
      moveDelta.y += moveAmount;
    }
    if (inputManager.isKeyPressed(LogicalKeyboardKey.keyA)) {
      moveDelta.x -= moveAmount;
    }
    if (inputManager.isKeyPressed(LogicalKeyboardKey.keyD)) {
      moveDelta.x += moveAmount;
    }

    // Apply the movement delta to the entity's position
    // Apply the movement delta to the entity's position
    if (moveDelta.length2 > 0) {
      // Check if delta is non-zero
      // print("  Moving entity $entityToControl by $moveDelta"); // Check movement calculation
      final oldPos = transform.position.clone();
      transform.position.add(moveDelta);
      // print("  New position: ${transform.position} (was $oldPos)"); // Check final position
      // Mark component as dirty if needed for optimizations later? (Not implemented yet)
    }
  }
}
