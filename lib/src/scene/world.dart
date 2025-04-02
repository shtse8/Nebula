import 'dart:collection';

import 'component.dart';
import 'entity.dart';
import 'system.dart';

/// The central class in the ECS architecture.
///
/// The World manages entities, components, and systems. It orchestrates the
/// game loop updates by executing systems in a defined order.
class World {
  // Entity Management
  int _nextEntityId = 0;
  final Set<Entity> _activeEntities = {};
  // TODO: Add pooling for recycled entity IDs if needed for performance.

  // Component Management
  // Stores components grouped by type for efficient access.
  // Map<Type, Map<Entity, Component>>
  final Map<Type, Map<Entity, Component>> _componentsByType = {};

  // System Management
  final List<System> _systems = [];
  final Map<Type, System> _systemByType = {};

  /// Creates a new entity in the world.
  /// Returns the unique ID of the created entity.
  Entity createEntity() {
    final entity = _nextEntityId++;
    _activeEntities.add(entity);
    // print('Created entity: $entity'); // Debugging
    return entity;
  }

  /// Destroys an entity and removes all its associated components.
  void destroyEntity(Entity entity) {
    if (_activeEntities.remove(entity)) {
      // Remove all components associated with this entity
      for (final componentMap in _componentsByType.values) {
        componentMap.remove(entity);
      }
      // print('Destroyed entity: $entity'); // Debugging
      // TODO: Add entity ID to a pool for recycling?
    }
  }

  /// Adds a component to the specified entity.
  /// Replaces existing component of the same type if present.
  /// Returns the added component instance.
  T addComponent<T extends Component>(Entity entity, T component) {
    if (!_activeEntities.contains(entity)) {
      throw ArgumentError(
        'Cannot add component to inactive or non-existent entity: $entity',
      );
    }
    final type = T; // Use reified type T
    final componentMap = _componentsByType.putIfAbsent(
      type,
      () => HashMap<Entity, Component>(),
    );
    componentMap[entity] = component;
    // print('Added component $type to entity $entity'); // Debugging
    return component;
  }

  /// Removes a component of the specified type from the entity.
  void removeComponent<T extends Component>(Entity entity) {
    final type = T;
    _componentsByType[type]?.remove(entity);
    // print('Removed component $type from entity $entity'); // Debugging
  }

  /// Gets the component of the specified type for the entity.
  /// Returns null if the entity does not have that component.
  T? getComponent<T extends Component>(Entity entity) {
    final type = T;
    return _componentsByType[type]?[entity] as T?;
  }

  /// Checks if an entity has a component of the specified type.
  bool hasComponent<T extends Component>(Entity entity) {
    final type = T;
    return _componentsByType[type]?.containsKey(entity) ?? false;
  }

  /// Queries for all entities that possess all the specified component types.
  /// Note: This is a basic implementation. More performant querying mechanisms
  /// (e.g., using archetypes or bitmasks) might be needed for complex scenarios.
  Iterable<Entity> queryEntities(List<Type> componentTypes) {
    if (componentTypes.isEmpty) {
      return List.unmodifiable(_activeEntities);
    }

    // Find the component type with the fewest entities for efficiency
    Type? smallestType;
    int minSize = -1;
    for (final type in componentTypes) {
      final size = _componentsByType[type]?.length ?? 0;
      if (minSize == -1 || size < minSize) {
        minSize = size;
        smallestType = type;
      }
    }

    if (smallestType == null || minSize == 0)
      return []; // No entities can match

    final initialSet = _componentsByType[smallestType]!.keys;
    if (componentTypes.length == 1) return initialSet;

    // Filter the initial set by checking for other required components
    return initialSet.where(
      (entity) {
        for (final type in componentTypes) {
          if (type == smallestType) continue;
          if (!(_componentsByType[type]?.containsKey(entity) ?? false)) {
            return false; // Entity is missing a required component
          }
        }
        return true; // Entity has all required components
      },
    ).toList(); // Convert to list to avoid issues with modifying during iteration elsewhere
  }

  /// Adds a system to the world.
  /// Systems are executed in the order they are added.
  T addSystem<T extends System>(T system) {
    if (_systemByType.containsKey(T)) {
      throw ArgumentError('System of type $T already exists in the world.');
    }
    system.world = this; // Inject world reference
    _systems.add(system);
    _systemByType[T] = system;
    system.onAdded(); // Call lifecycle method
    // print('Added system: $T'); // Debugging
    return system;
  }

  /// Removes a system from the world.
  void removeSystem<T extends System>() {
    final system = _systemByType.remove(T);
    if (system != null) {
      _systems.remove(system);
      system.onRemoved(); // Call lifecycle method
      // print('Removed system: $T'); // Debugging
    }
  }

  /// Gets a system instance by its type.
  T? getSystem<T extends System>() {
    return _systemByType[T] as T?;
  }

  /// Updates all registered systems in the order they were added.
  /// This is typically called once per frame by the game loop.
  void update(Duration deltaTime) {
    for (final system in _systems) {
      system.update(deltaTime);
    }
  }
}
