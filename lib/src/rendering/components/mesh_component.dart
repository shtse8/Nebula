import 'dart:typed_data';
import 'dart:ui' show Vertices, VertexMode, Offset; // Add Offset

import '../../scene/component.dart';
// Potentially import MaterialComponent later

/// Component holding geometry data for rendering a 2D mesh using Canvas.drawVertices.
class MeshComponent extends Component {
  /// Vertex positions as a list of 2D offsets.
  List<Offset>? positions;

  /// Indices defining the triangles (or lines/points) of the mesh.
  /// If null, vertices are assumed to be in triangle order (or line/point order
  /// depending on the draw mode).
  Uint16List? indices;

  /// How the vertices should be interpreted (triangles, lines, points, etc.).
  VertexMode vertexMode;

  // TODO: Add reference to a MaterialComponent when materials are implemented.
  // MaterialComponent? material;

  /// Creates a MeshComponent.
  MeshComponent({
    this.positions,
    this.indices,
    this.vertexMode = VertexMode.triangles, // Default to triangles
    // this.material,
  });

  /// Creates a Flutter Vertices object from the component data.
  /// Returns null if vertex data is missing.
  Vertices? get verticesObject {
    if (positions == null) {
      return null;
    }
    // Note: Colors and texture coordinates are often passed via Paint/Shader,
    // but Vertices can optionally include them directly if needed.
    // For now, we assume they are handled by the shader/material.
    return Vertices(
      vertexMode,
      positions!, // Use the List<Offset>
      indices: indices,
      // colors: provide colors list if needed,
      // textureCoordinates: provide texture coordinates list if needed,
    );
  }
}
