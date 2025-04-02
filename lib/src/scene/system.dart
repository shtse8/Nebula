import 'world.dart';

/// Base class for all systems in the ECS architecture.
///
/// Systems contain the logic that operates on entities possessing specific
/// sets of components. They are managed and executed by the [World].
abstract class System {
  /// A reference to the world the system belongs to.
  /// Set automatically when the system is added to the world.
  late final World world;

  /// Called once per frame to update the system's logic.
  ///
  /// [deltaTime] is the time elapsed since the last frame.
  /// Implementations will typically query the [world] for relevant entities
  /// and operate on their components.
  void update(Duration deltaTime);

  /// Optional: Called when the system is added to the world.
  void onAdded() {}

  /// Optional: Called when the system is removed from the world.
  void onRemoved() {}
}
