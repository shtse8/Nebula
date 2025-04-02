/// Nebula Engine: A high-performance 2D/3D game engine for Flutter.
library nebula_engine;

// Core engine components

// Rendering system
export 'src/rendering/renderer.dart';
export 'src/rendering/render_system.dart';

// ECS (Entity-Component-System) Core
export 'src/scene/world.dart';
export 'src/scene/entity.dart'; // Now a typedef Entity = int;
export 'src/scene/component.dart';
export 'src/scene/components/transform_component.dart';
export 'src/rendering/components/sprite_component.dart';
export 'src/scene/system.dart';

// Asset management
export 'src/assets/asset_manager.dart';

// Physics integration (interfaces)
export 'src/physics/physics_world.dart';
export 'src/physics/components/rigidbody_component.dart';
export 'src/physics/components/collider_component.dart';
export 'src/physics/components/circle_collider_component.dart';
export 'src/physics/components/rectangle_collider_component.dart';
export 'src/physics/physics_system.dart';

// Input management
export 'src/input/input_manager.dart';
export 'src/input/input_system.dart';

// User-facing Widgets
export 'game_widget.dart';

// TODO: Export other necessary utilities, data structures, etc. as they are created.
