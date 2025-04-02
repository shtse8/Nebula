import 'dart:typed_data';
import 'dart:ui' show VertexMode; // Only need VertexMode enum now

import '../../scene/component.dart';
// Potentially import MaterialComponent later

/// Component holding geometry data for rendering a 3D mesh.
class MeshComponent extends Component {
  /// Raw vertex data (positions, potentially interleaved with normals, UVs, colors).
  /// The exact layout depends on the shader and rendering pipeline expectations.
  /// Example layout: [x0, y0, z0, u0, v0, nx0, ny0, nz0, x1, y1, z1, ...]
  Float32List? vertices;

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
    this.vertices,
    this.indices,
    this.vertexMode = VertexMode.triangles, // Default to triangles
    // this.material,
  });
}
