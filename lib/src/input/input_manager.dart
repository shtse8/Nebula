import 'dart:ui'
    show Offset, PointerDeviceKind; // Import Offset and PointerDeviceKind
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/gestures.dart'
    show kPrimaryMouseButton, kSecondaryMouseButton, kMiddleMouseButton;

/// Manages user input state from various sources (keyboard, mouse, touch).
///
/// This class stores the current and frame-specific input states. It provides
/// methods to update the state (intended to be called by external listeners)
/// and query methods for systems to check input.
class InputManager {
  // --- State Tracking ---

  // Keyboard state
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  final Set<LogicalKeyboardKey> _justPressedKeys = {};
  final Set<LogicalKeyboardKey> _justReleasedKeys = {};

  // Pointer state (Mouse & Touch)
  // Using device ID + pointer ID as a unique key for multi-touch/multi-device is complex.
  // For simplicity now, we'll use pointer ID directly, assuming they are unique enough
  // across devices during a session, which is generally true for Flutter events.
  final Map<int, Offset> _pointerPositions = {}; // pointerId -> position
  final Map<int, PointerDeviceKind> _pointerKinds = {}; // pointerId -> kind
  final Set<int> _pressedMouseButtons = {}; // Using Flutter's button constants
  final Set<int> _justPressedMouseButtons = {};
  final Set<int> _justReleasedMouseButtons = {};
  Offset _mousePosition = Offset.zero; // Last known mouse position

  // TODO: Add gamepad state tracking

  // --- Event Handling Methods (Called by external listeners, e.g., in GameWidget) ---

  /// Called when a key is pressed down.
  void onKeyDown(LogicalKeyboardKey key) {
    // Add to justPressed only if it wasn't already pressed in a previous frame
    if (_pressedKeys.add(key)) {
      _justPressedKeys.add(key);
    }
  }

  /// Called when a key is released.
  void onKeyUp(LogicalKeyboardKey key) {
    if (_pressedKeys.remove(key)) {
      _justReleasedKeys.add(key);
    }
  }

  /// Called when a pointer (touch/mouse) goes down or button is pressed.
  void onPointerDown(
    int pointerId,
    PointerDeviceKind kind,
    Offset position,
    int buttons,
  ) {
    _pointerPositions[pointerId] = position;
    _pointerKinds[pointerId] = kind;
    if (kind == PointerDeviceKind.mouse) {
      _mousePosition = position;
      // Check individual buttons - Flutter's `buttons` is a bitmask
      _updateMouseButtonState(buttons, isDown: true);
    }
    // TODO: Handle touch-specific down logic if needed
  }

  /// Called when a pointer (touch/mouse) moves.
  void onPointerMove(int pointerId, Offset position) {
    if (_pointerPositions.containsKey(pointerId)) {
      // Only track known pointers
      _pointerPositions[pointerId] = position;
      if (_pointerKinds[pointerId] == PointerDeviceKind.mouse) {
        _mousePosition = position;
      }
    }
    // Note: PointerMoveEvent doesn't reliably report button state changes during drag.
    // We rely on PointerDown/Up/Signal for button state.
  }

  /// Called when a pointer (touch/mouse) goes up or button is released.
  void onPointerUp(int pointerId, Offset position, int buttons) {
    // Update position one last time
    _pointerPositions[pointerId] = position;
    if (_pointerKinds[pointerId] == PointerDeviceKind.mouse) {
      _mousePosition = position;
    }

    // Check which mouse buttons were released
    _updateMouseButtonState(buttons, isDown: false);

    // Remove pointer info after processing button release
    _pointerPositions.remove(pointerId);
    _pointerKinds.remove(pointerId);
    // TODO: Handle touch-specific up logic if needed
  }

  /// Called for mouse-specific events like button changes during hover or scroll wheel.
  void onPointerSignal(
    int pointerId,
    Offset position,
    int buttons /*, Scroll details etc */,
  ) {
    if (_pointerKinds[pointerId] == PointerDeviceKind.mouse) {
      _mousePosition = position;
      _updateMouseButtonState(
        buttons,
        isDown: null,
      ); // Update based on current state
      // TODO: Handle scroll events from PointerSignalEvent if needed
    }
  }

  /// Called when a pointer event is cancelled (e.g., focus lost).
  void onPointerCancel(int pointerId) {
    // Treat cancel like pointer up - release everything associated with it
    _updateMouseButtonState(0, isDown: false); // Assume all buttons released

    _pointerPositions.remove(pointerId);
    _pointerKinds.remove(pointerId);
  }

  /// Helper to update mouse button states and transient flags.
  void _updateMouseButtonState(int currentButtons, {bool? isDown}) {
    final buttonsToCheck = [
      kPrimaryMouseButton,
      kSecondaryMouseButton,
      kMiddleMouseButton,
    ];
    for (final button in buttonsToCheck) {
      final currentlyPressed = (currentButtons & button) != 0;
      final wasPressed = _pressedMouseButtons.contains(button);

      if (isDown != null) {
        // Handle definite down/up events
        if (isDown && currentlyPressed && !wasPressed) {
          // Just pressed
          _pressedMouseButtons.add(button);
          _justPressedMouseButtons.add(button);
        } else if (!isDown && !currentlyPressed && wasPressed) {
          // Just released
          _pressedMouseButtons.remove(button);
          _justReleasedMouseButtons.add(button);
        }
      } else {
        // Handle signal events (update based on current state only)
        if (currentlyPressed && !wasPressed) {
          // Pressed during signal/hover
          _pressedMouseButtons.add(button);
          _justPressedMouseButtons.add(button);
        } else if (!currentlyPressed && wasPressed) {
          // Released during signal/hover
          _pressedMouseButtons.remove(button);
          _justReleasedMouseButtons.add(button);
        }
      }
    }
  }

  /// Clears the "just pressed" and "just released" states.
  /// Should be called once per frame, usually at the end of the update cycle by InputSystem.
  void clearTransientState() {
    _justPressedKeys.clear();
    _justReleasedKeys.clear();
    _justPressedMouseButtons.clear();
    _justReleasedMouseButtons.clear();
  }

  // --- Query Methods ---

  /// Checks if a specific keyboard key is currently held down.
  bool isKeyPressed(LogicalKeyboardKey key) {
    return _pressedKeys.contains(key);
  }

  /// Checks if a specific key was just pressed down in the current frame.
  bool isKeyJustPressed(LogicalKeyboardKey key) {
    return _justPressedKeys.contains(key);
  }

  /// Checks if a specific key was just released in the current frame.
  bool isKeyJustReleased(LogicalKeyboardKey key) {
    return _justReleasedKeys.contains(key);
  }

  /// Checks if a specific mouse button is currently held down.
  /// Use constants like `kPrimaryMouseButton`.
  bool isMouseButtonPressed(int buttonId) {
    return _pressedMouseButtons.contains(buttonId);
  }

  /// Checks if a specific mouse button was just pressed down in the current frame.
  bool isMouseButtonJustPressed(int buttonId) {
    return _justPressedMouseButtons.contains(buttonId);
  }

  /// Checks if a specific mouse button was just released in the current frame.
  bool isMouseButtonJustReleased(int buttonId) {
    return _justReleasedMouseButtons.contains(buttonId);
  }

  /// Gets the last known mouse position relative to the game widget.
  Offset get mousePosition => _mousePosition;

  /// Gets the position of a specific pointer (touch or mouse).
  /// Returns null if the pointer is not currently active.
  Offset? getPointerPosition(int pointerId) {
    return _pointerPositions[pointerId];
  }

  /// Gets the kind of a specific pointer.
  /// Returns null if the pointer is not currently active.
  PointerDeviceKind? getPointerKind(int pointerId) {
    return _pointerKinds[pointerId];
  }

  /// Gets all active pointer positions.
  Map<int, Offset> get activePointers => Map.unmodifiable(_pointerPositions);

  // TODO: Add methods for gamepad input querying.
  // TODO: Add methods for scroll wheel.
}
