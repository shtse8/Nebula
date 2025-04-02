# Active Context: Nebula Engine (Basic Loop, Render, Input Working)

## 1. Current Focus

*   Confirmed basic rendering pipeline works via example app using Ticker-based updates.
*   Confirmed basic Input handling (`InputManager`, `InputSystem`, `GameWidget` listeners) and usage (`PlayerControlSystem`) are working.
*   Physics integration remains blocked by unresolved `forge2d` build errors.

## 2. Recent Changes

*   **Game Loop:** Replaced `GameLoop` class with `Ticker` logic within `_GameWidgetState` for driving updates and repaints. Removed `game_loop.dart`.
*   **Input:** Created `PlayerControlSystem` in example to demonstrate using `InputManager` state to modify `TransformComponent`. Confirmed working. Removed debug prints from `GameWidget`.
*   **Assets/Sprites:** Fixed `RenderSystem` to draw sprites at a fixed size. Confirmed working.
*   **Vector Math:** Standardized usage to base `package:vector_math/vector_math.dart` across physics components, transform component, and example. Fixed related build errors.
*   **Physics Debugging:** Build errors persist even after updating `forge2d` to `^0.14.0` and trying various fixes. Physics code remains commented out.

## 3. Next Steps

*   Update `progress.md` to reflect the current state.
*   **Rendering Enhancements:**
    *   Incorporate `TransformComponent`'s scale and rotation into sprite rendering in `RenderSystem`.
    *   Define `MeshComponent`.
    *   Implement mesh drawing in `Renderer` / `RenderSystem`.
*   **(Later) Physics Debugging:** Revisit `forge2d` build errors.
*   **(Later) Physics System Refinement:** Implement entity lifecycle handling.
*   **Asset Loading:** Implement loading for other asset types (models, audio, JSON).

## 4. Active Decisions & Considerations

*   **Architecture:** ECS adopted. Ticker used for game loop.
*   **Dependencies:** `vector_math`, `forge2d` added.
*   **Build Errors:** `forge2d` API usage errors persist. Physics code remains disabled.
*   **Next Immediate Action:** Update `progress.md`.