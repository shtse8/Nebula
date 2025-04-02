# Active Context: Nebula Engine (3D Rendering Foundation)

## 1. Current Focus

*   Setting up foundational elements for 3D rendering (Camera, Renderer updates).
*   Basic 2D rendering (sprites) and input control remain functional.
*   Physics integration remains blocked.

## 2. Recent Changes

*   **3D Setup:**
    *   Created basic `Camera` class (`lib/src/rendering/camera.dart`) with view/projection matrix calculations and exported it.
    *   Updated `Renderer` interface and `NebulaRenderer` implementation to accept a `Camera` and added placeholder `drawVertices` method (`lib/src/rendering/renderer.dart`).
    *   Updated `RenderSystem` to hold and set the `Camera` (`lib/src/rendering/render_system.dart`).
    *   Updated `GameWidget` to create and provide the `Camera` instance (`lib/game_widget.dart`).
*   **Rendering:** Incorporated `TransformComponent` scale/rotation into `RenderSystem` sprite drawing logic.
*   Previous work on Ticker-based loop, input handling, asset loading, sprite rendering, and vector math standardization remains completed.
*   Physics code remains commented out due to persistent build errors.

## 3. Next Steps

*   Update `progress.md` to reflect the current state.
*   Update `progress.md` to reflect the current state.
*   **3D Rendering Implementation:**
    *   Define `MeshComponent` (vertex data, indices, etc.).
    *   Implement `Renderer.drawVertices` logic, including applying camera and model transformations (MVP matrix).
    *   Update `RenderSystem` to query for and draw entities with `MeshComponent`.
*   **Asset Loading:** Implement loading for 3D model formats (e.g., basic OBJ or glTF).
*   **(Later) Physics Debugging:** Revisit `forge2d` build errors.
*   **(Later) Physics System Refinement:** Implement entity lifecycle handling.

## 4. Active Decisions & Considerations

*   **Architecture:** ECS adopted. Ticker used for game loop.
*   **Dependencies:** `vector_math`, `forge2d` added.
*   **Build Errors:** `forge2d` API usage errors persist. Physics code remains disabled.
*   **Next Immediate Action:** Update `progress.md`.