import '../scene/system.dart';
import 'input_manager.dart';

/// System responsible for managing the input state transitions.
///
/// Primarily, it clears the transient ("just pressed"/"just released") input
/// states at the end of each frame update cycle.
class InputSystem extends System {
  late final InputManager inputManager;

  /// Creates an InputSystem. Requires an [InputManager] instance.
  InputSystem(this.inputManager);

  @override
  void update(Duration deltaTime) {
    // The main work of the InputSystem is often done at the *end* of the frame
    // to clear transient states for the *next* frame. We achieve this by
    // calling clearTransientState() here, assuming the InputSystem runs late
    // in the system execution order. Alternatively, the GameLoop or World
    // could manage calling clearTransientState() after all systems update.
    // For simplicity now, we'll do it here.

    inputManager.clearTransientState();

    // This system could also be used to:
    // - Poll inputManager state and update specific input components on entities.
    // - Trigger input-related events.
    // print('InputSystem update tick');
  }
}
