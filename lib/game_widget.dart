import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math.dart'; // Import vector_math

import 'nebula_engine.dart'; // Import the engine exports

/// A Flutter widget that hosts and runs a Nebula Engine instance.
class GameWidget extends StatefulWidget {
  /// Optional builder function to add initial entities and systems to the world.
  /// Provides the World and AssetManager for setup convenience.
  final void Function(World world, AssetManager assetManager)? setupWorld;

  const GameWidget({super.key, this.setupWorld});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

// Add SingleTickerProviderStateMixin
class _GameWidgetState extends State<GameWidget>
    with SingleTickerProviderStateMixin {
  late final World world;
  // late final GameLoop gameLoop; // Remove GameLoop instance
  late final Ticker _ticker; // Add Ticker instance
  Duration _lastTickTime = Duration.zero; // Track time for delta calculation
  late final Renderer renderer;
  RenderSystem? renderSystem;
  late final InputManager inputManager;
  late final AssetManager assetManager; // Add AssetManager instance
  final FocusNode _focusNode = FocusNode();
  late final Camera camera; // Add Camera instance

  @override
  void initState() {
    super.initState();
    print("Initializing GameWidget State...");

    // 1. Create the core engine parts
    world = World();
    renderer = NebulaRenderer(); // Use the concrete implementation
    // gameLoop = GameLoop(world); // Remove GameLoop creation
    inputManager = InputManager();
    assetManager = AssetManager();
    camera =
        Camera()
          ..position.z =
              500.0 // Keep camera pulled back
          ..target = Vector3(75.0, 75.0, 0.0); // Look towards the entities

    // 2. Add core systems (Order can matter!)
    // Add RenderSystem first so it's available for the painter
    // Pass camera to RenderSystem
    renderSystem = world.addSystem(RenderSystem(renderer, camera));
    // Add PhysicsSystem
    // world.addSystem(PhysicsSystem()); // Temporarily commented out due to build error
    // Add InputSystem, passing the InputManager
    world.addSystem(InputSystem(inputManager));

    // 3. Allow user to add initial game setup
    // Pass AssetManager to setupWorld
    widget.setupWorld?.call(world, assetManager);

    // 4. Create and start the Ticker
    _ticker = createTicker(_tick);
    _ticker.start();
    print("Game Ticker started.");
    print("GameWidget State Initialized. GameLoop started.");
    // Request focus for keyboard events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still mounted
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    // Note: Requesting focus in initState might be too early.
    // It's often better done in build or via autofocus on the Focus widget.
  }

  @override
  void dispose() {
    print("Disposing GameWidget State...");
    _ticker.dispose(); // Dispose the Ticker
    // gameLoop.stop(); // No longer needed
    // gameLoop.dispose(); // No longer needed
    assetManager.clearCache(); // Clear asset cache on dispose
    // TODO: Add any other necessary cleanup for world, systems, renderer?
    print("GameLoop stopped.");
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("_GameWidgetState build called"); // Debug print
    // Ensure the widget has focus to receive keyboard events
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }

    // Use Focus and Listener widgets to capture input
    return Focus(
      focusNode: _focusNode,
      autofocus: true, // Attempt to grab focus automatically
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          inputManager.onKeyDown(event.logicalKey);
          return KeyEventResult.handled;
        } else if (event is KeyUpEvent) {
          inputManager.onKeyUp(event.logicalKey);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (details) {
          inputManager.onPointerDown(
            details.pointer,
            details.kind,
            details.localPosition,
            details.buttons,
          );
        },
        onPointerMove:
            (details) => inputManager.onPointerMove(
              details.pointer,
              details.localPosition,
            ),
        onPointerUp:
            (details) => inputManager.onPointerUp(
              details.pointer,
              details.localPosition,
              details.buttons,
            ),
        onPointerCancel:
            (details) => inputManager.onPointerCancel(details.pointer),
        onPointerSignal: (details) {
          // Handle mouse-specific signals like button changes during hover or scroll
          if (details is PointerScrollEvent) {
            // TODO: Handle scroll: details.scrollDelta
          } else if (details is PointerHoverEvent) {
            // PointerSignalEvent might carry button info during hover
            inputManager.onPointerSignal(
              details.pointer,
              details.localPosition,
              details.buttons,
            );
          }
        },
        // Use CustomPaint to trigger rendering via the RenderSystem
        child: CustomPaint(
          painter: _GamePainter(renderSystem),
          child:
              Container(), // Opaque child needed for CustomPaint to get size and hit testing
        ),
      ),
    );
  }

  /// The callback executed by the Ticker on each frame.
  void _tick(Duration elapsed) {
    // Calculate delta time since last tick
    if (_lastTickTime == Duration.zero) {
      _lastTickTime = elapsed;
      return; // Skip first frame to establish baseline
    }
    final deltaTime = elapsed - _lastTickTime;
    _lastTickTime = elapsed;

    // Update the world
    try {
      world.update(deltaTime);
    } catch (e, stackTrace) {
      print('Error during world update: $e\n$stackTrace');
      // Consider stopping ticker on error?
      // _ticker.stop();
    }

    // Trigger a rebuild/repaint
    if (mounted) {
      setState(() {});
    }
  }
}

/// CustomPainter that delegates painting to the RenderSystem.
class _GamePainter extends CustomPainter {
  final RenderSystem? renderSystem;

  _GamePainter(this.renderSystem);

  @override
  void paint(Canvas canvas, Size size) {
    // print("_GamePainter paint called"); // Debug print
    if (renderSystem == null) {
      print("Warning: GamePainter.paint called but RenderSystem is null.");
      return;
    }
    // The RenderSystem now handles beginFrame, drawing, endFrame
    renderSystem!.render(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint every frame because the game state changes continuously.
    return true;
  }
}
