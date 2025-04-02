import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Use alias for dart:ui
import 'package:flutter/material.dart' hide Image; // Hide Image widget
import 'package:nebula_engine/nebula_engine.dart';
import 'package:vector_math/vector_math.dart'; // Use base vector_math
import 'debug_input_system.dart';
import 'player_control_system.dart'; // Import the control system

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula Engine Example',
      theme: ThemeData.dark(), // Use a dark theme for contrast
      home: Scaffold(
        // Remove const here
        appBar: null, // No app bar for a cleaner game view
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9, // Example aspect ratio
            child: GameWidget(setupWorld: _setupSampleWorld),
          ),
        ),
      ),
    );
  }
}

/// Example setup function to add entities to the world.
// Make setup async to await asset loading
Future<void> _setupSampleWorld(World world, AssetManager assetManager) async {
  print("Setting up sample world...");

  // Create a single entity at position (50, 50)
  final entity1 = world.createEntity();
  // Set initial scale to make the sprite smaller
  final transform1 = TransformComponent(
    position: Vector3(50, 50, 0),
    scale: Vector3.all(0.1),
  );
  world.addComponent(entity1, transform1);

  // Create another entity at (100, 100)
  final entity2 = world.createEntity();
  world.addComponent(
    entity2,
    // Set initial scale here too
    TransformComponent(position: Vector3(100, 100, 0), scale: Vector3.all(0.1)),
  );
  final transform2 = world.getComponent<TransformComponent>(entity2)!;

  // Add the debug input system
  world.addSystem(DebugInputSystem()); // Add debug first
  world.addSystem(PlayerControlSystem()); // Add player control

  // Load the placeholder image
  try {
    // Explicitly load dart:ui.Image
    final placeholderImage = await assetManager.load<ui.Image>(
      'assets/images/placeholder.png',
    );

    // Add SpriteComponent to entities
    world.addComponent(
      entity1,
      SpriteComponent(image: placeholderImage), // No cast needed
    );
    world.addComponent(
      entity2,
      SpriteComponent(image: placeholderImage), // No cast needed
    );

    print(
      "Sample world setup complete. Entities created: $entity1, $entity2. Image loaded.",
    );
  } catch (e) {
    print("Error loading placeholder image: $e");
    print(
      "Sample world setup complete (without image). Entities created: $entity1, $entity2.",
    );
  }
}
