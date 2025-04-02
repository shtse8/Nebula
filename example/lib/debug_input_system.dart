import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'; // For mouse button constants
import 'package:nebula_engine/nebula_engine.dart';

/// A simple system that prints input state for debugging.
class DebugInputSystem extends System {
  late final InputManager inputManager;

  @override
  void onAdded() {
    // Get the InputManager from the world when added
    inputManager = world.getSystem<InputSystem>()!.inputManager;
  }

  @override
  void update(Duration deltaTime) {
    // Check for specific key presses
    if (inputManager.isKeyJustPressed(LogicalKeyboardKey.keyW)) {
      print("Input Debug: W key just pressed");
    }
    if (inputManager.isKeyPressed(LogicalKeyboardKey.keyA)) {
      print("Input Debug: A key is held");
    }
    if (inputManager.isKeyJustReleased(LogicalKeyboardKey.keyS)) {
      print("Input Debug: S key just released");
    }

    // Check mouse buttons
    if (inputManager.isMouseButtonJustPressed(kPrimaryMouseButton)) {
      print(
        "Input Debug: Left Mouse Button just pressed at ${inputManager.mousePosition}",
      );
    }
    if (inputManager.isMouseButtonPressed(kSecondaryMouseButton)) {
      print(
        "Input Debug: Right Mouse Button is held at ${inputManager.mousePosition}",
      );
    }
    if (inputManager.isMouseButtonJustReleased(kMiddleMouseButton)) {
      print("Input Debug: Middle Mouse Button just released");
    }

    // Check active pointers (touch)
    // final pointers = inputManager.activePointers;
    // if (pointers.isNotEmpty) {
    //    print("Input Debug: Active pointers: ${pointers.keys.toList()}");
    // }
  }
}
