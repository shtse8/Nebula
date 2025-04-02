# Technical Context: Nebula Engine

## 1. Core Technologies

*   **Language:** Dart (latest stable version)
*   **Framework:** Flutter (latest stable version)
*   **Rendering Backend:** Flutter's rendering engine (Skia/Impeller via `dart:ui`)

## 2. Development Environment

*   **IDE:** VS Code / Android Studio / IntelliJ IDEA with Dart/Flutter plugins.
*   **Build System:** Flutter CLI (`flutter build`, `flutter run`)
*   **Package Manager:** Pub (`pubspec.yaml`)

## 3. Key Dependencies (Anticipated)

*   `vector_math`: For mathematical operations (vectors, matrices).
*   `collection`: Useful data structures.
*   **(To Be Determined):** Physics Engine (e.g., `forge2d` for 2D, potential 3D solutions).
*   **(To Be Determined):** Image loading/processing library (if Flutter's built-in is insufficient).
*   **(To Be Determined):** Model loading library (e.g., for glTF).
*   **(To Be Determined):** Testing frameworks (`test`, `flutter_test`).

## 4. Technical Constraints & Considerations

*   **Performance:** Must be highly performant on target platforms (iOS, Android, Web, Desktop). Need to be mindful of Dart's single-threaded nature and leverage Isolates appropriately.
*   **Flutter Engine Integration:** Deep reliance on Flutter's rendering pipeline. Changes in Flutter could impact the engine. Need to stay updated with Flutter releases.
*   **Web Limitations:** Performance and feature parity on the web (WASM/CanvasKit/HTML renderer) might require specific considerations or workarounds.
*   **Shader Language:** Likely GLSL (via Flutter's shader support) or potentially a custom solution/abstraction.
*   **Platform Differences:** Handling nuances between different target platforms (input methods, file system access, performance characteristics).

## 5. Tooling & Infrastructure

*   **Version Control:** Git / GitHub
*   **CI/CD:** GitHub Actions
*   **Documentation:** DartDoc generation, potentially combined with a static site generator (like Jekyll or Docusaurus) for GitHub Pages.
*   **Publishing:** `pub.dev` via CI/CD pipeline.