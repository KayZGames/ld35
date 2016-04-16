part of shared;

class GeometryGenerator {
  static Geometry createCircle() {
    final vertices = new List(verticeCount + 1);
    final indices = new List(verticeCount * 3);
    vertices[0] = new Vector3(0.0, 0.0, 0.0);
    for (int i = 0; i < verticeCount; i++) {
      final index = i + 1;
      final angle = -PI/4 + 2 * PI * i / verticeCount;
      vertices[index] = new Vector3(cos(angle), sin(angle), 0.0);

      indices[i * 3] = 0;
      indices[i * 3 + 1] = index;
      indices[i * 3 + 2] = index + 1;
    }
    indices[verticeCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }

  static Geometry createSquare() {
    final vertices = new List(verticeCount + 1);
    final indices = new List(verticeCount * 3);
    vertices[0] = new Vector3(0.0, 0.0, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < verticeCount ~/ 4; j++) {
        final index = i * (verticeCount ~/ 4) + j + 1;
        final angle = -PI/4 + 2 * PI * (i * (verticeCount ~/ 4) + j) / verticeCount;
        var x = cos(angle);
        var y = sin(angle);
        switch (i) {
          case 0:
            x = 1.0;
            y = -1.0 + 2 * (j / (verticeCount ~/ 4));
            break;
          case 1:
            x = 1.0 - 2 * (j / (verticeCount ~/ 4));
            y = 1.0;
            break;
          case 2:
            x = -1.0;
            y = 1.0 - 2 * (j / (verticeCount ~/ 4));
            break;
          case 3:
            x = -1.0 + 2 * (j / (verticeCount ~/ 4));
            y = -1.0;
            break;
        }
        vertices[index] = new Vector3(x, y, 0.0);

        indices[(i * (verticeCount ~/ 4) + j) * 3] = 0;
        indices[(i * (verticeCount ~/ 4) + j) * 3 + 1] = index;
        indices[(i * (verticeCount ~/ 4) + j) * 3 + 2] = index + 1;
      }
    }
    indices[verticeCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }
}

class Geometry {
  List<Vector3> vertices;
  List<int> indices;
  Geometry(this.vertices, this.indices);
}