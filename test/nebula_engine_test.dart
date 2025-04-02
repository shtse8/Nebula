import 'package:flutter_test/flutter_test.dart';

import 'package:nebula_engine/nebula_engine.dart';

// Define a simple component for testing purposes
class Position extends Component {
  double x = 0.0;
  double y = 0.0;

  Position({this.x = 0.0, this.y = 0.0});
}

// Define a simple system for testing
class MovementSystem extends System {
  @override
  void update(Duration deltaTime) {
    // Get all entities with a Position component
    final entities = world.queryEntities([Position]);
    for (final entity in entities) {
      final pos = world.getComponent<Position>(entity);
      if (pos != null && pos.isEnabled) {
        // Example logic: move entities slightly
        pos.x += 1.0 * deltaTime.inMilliseconds / 1000.0;
        pos.y += 0.5 * deltaTime.inMilliseconds / 1000.0;
      }
    }
  }
}

void main() {
  group('ECS Core Tests', () {
    late World world;

    setUp(() {
      world = World();
    });

    test('World can be created', () {
      expect(world, isNotNull);
    });

    test('Entity can be created', () {
      final entity = world.createEntity();
      expect(entity, isA<Entity>()); // Entity is typedef int
      expect(entity, greaterThanOrEqualTo(0));
    });

    test('Component can be added to an entity', () {
      final entity = world.createEntity();
      final position = Position(x: 10, y: 20);
      expect(
        () => world.addComponent<Position>(entity, position),
        returnsNormally,
      );
    });

    test('Component can be retrieved from an entity', () {
      final entity = world.createEntity();
      final position = Position(x: 10, y: 20);
      world.addComponent<Position>(entity, position);

      final retrievedPosition = world.getComponent<Position>(entity);
      expect(retrievedPosition, isNotNull);
      expect(retrievedPosition, isA<Position>());
      expect(retrievedPosition?.x, 10);
      expect(retrievedPosition?.y, 20);
    });

    test('Entity can be destroyed', () {
      final entity = world.createEntity();
      world.addComponent<Position>(entity, Position());
      expect(world.hasComponent<Position>(entity), isTrue);

      world.destroyEntity(entity);

      expect(world.hasComponent<Position>(entity), isFalse);
      // Attempting to get component should return null
      expect(world.getComponent<Position>(entity), isNull);
    });

    test('System can be added and retrieved', () {
      final system = MovementSystem();
      expect(() => world.addSystem<MovementSystem>(system), returnsNormally);
      final retrievedSystem = world.getSystem<MovementSystem>();
      expect(retrievedSystem, isNotNull);
      expect(retrievedSystem, isA<MovementSystem>());
    });

    test('World update calls system update', () {
      final entity = world.createEntity();
      final position = Position(x: 0, y: 0);
      world.addComponent<Position>(entity, position);
      world.addSystem(MovementSystem());

      // Simulate a short time delta
      world.update(const Duration(milliseconds: 100));

      final updatedPosition = world.getComponent<Position>(entity);
      expect(updatedPosition?.x, greaterThan(0)); // Expect x to have increased
      expect(updatedPosition?.y, greaterThan(0)); // Expect y to have increased
    });

    test('Query entities returns entities with correct components', () {
      final entity1 = world.createEntity();
      world.addComponent(entity1, Position(x: 1, y: 1));

      final entity2 = world.createEntity(); // No position component

      final entity3 = world.createEntity();
      world.addComponent(entity3, Position(x: 3, y: 3));

      final positionEntities = world.queryEntities([Position]);
      expect(positionEntities, isNotNull);
      expect(positionEntities.length, 2);
      expect(positionEntities.contains(entity1), isTrue);
      expect(positionEntities.contains(entity3), isTrue);
      expect(positionEntities.contains(entity2), isFalse);
    });
  });
}
