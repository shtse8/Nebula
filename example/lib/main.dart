import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image; // Only import Image with alias
import 'dart:ui' show Offset; // Import Offset directly
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
    // Set scale to desired pixel size (e.g., 50x50)
    scale: Vector3(50.0, 50.0, 1.0),
  );
  world.addComponent(entity1, transform1);

  // Create another entity at (100, 100)
  final entity2 = world.createEntity();
  world.addComponent(
    entity2,
    // Set initial scale here too
    // Set scale here too
    TransformComponent(
      position: Vector3(100, 100, 0),
      scale: Vector3.all(1.0), // Reset scale for mesh entity
    ),
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
    world.addComponent(entity1, SpriteComponent(image: placeholderImage));

    // Add a MeshComponent to entity2 (simple triangle)
    world.addComponent(
      entity2,
      MeshComponent(
        positions: [
          const Offset(-20, -20), // Bottom-left
          const Offset(20, -20), // Bottom-right
          const Offset(0, 20), // Top-center
        ],
        // No indices needed for a single triangle with VertexMode.triangles
      ),
    );
    // Remove the SpriteComponent from entity2 so only the mesh is rendered

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
