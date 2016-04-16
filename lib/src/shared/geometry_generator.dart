part of shared;

typedef Geometry ShapeGenerator();

class GeometryGenerator {

  static List<ShapeGenerator> shapeGenerators = [createCircle, createSquare];

  static Geometry createCircle() {
    final verticesPerSegment = 3;
    final verticeCount = verticesPerSegment * (segmentCount + 1);
    final vertices = new List(verticeCount);
    final indices = new List(segmentCount * verticesPerSegment);
    vertices[0] = 0.0;
    vertices[1] = 0.0;
    vertices[2] = 0.0;
    for (int i = 0; i < segmentCount; i++) {
      final index = verticesPerSegment * (i + 1);
      final angle = -PI/4 + 2 * PI * i / segmentCount;
      vertices[index] = cos(angle);
      vertices[index + 1] = sin(angle);
      vertices[index + 2] = 0.0;

      indices[i * 3] = 0;
      indices[i * 3 + 1] = index ~/ verticesPerSegment;
      indices[i * 3 + 2] = index ~/ verticesPerSegment + 1;
    }
    indices[segmentCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }

  static Geometry createSquare() {
    final verticesPerSegment = 3;
    final verticeCount = verticesPerSegment * (segmentCount + 1);
    final vertices = new List(verticeCount);
    final indices = new List(segmentCount * verticesPerSegment);
    vertices[0] = 0.0;
    vertices[1] = 0.0;
    vertices[2] = 0.0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < segmentCount ~/ 4; j++) {
        final index = verticesPerSegment * (i * (segmentCount ~/ 4) + j + 1);
        final angle = -PI/4 + 2 * PI * (i * (segmentCount ~/ 4) + j) / segmentCount;
        var x = cos(angle);
        var y = sin(angle);
        switch (i) {
          case 0:
            x = 1.0;
            y = -1.0 + 2 * (j / (segmentCount ~/ 4));
            break;
          case 1:
            x = 1.0 - 2 * (j / (segmentCount ~/ 4));
            y = 1.0;
            break;
          case 2:
            x = -1.0;
            y = 1.0 - 2 * (j / (segmentCount ~/ 4));
            break;
          case 3:
            x = -1.0 + 2 * (j / (segmentCount ~/ 4));
            y = -1.0;
            break;
        }
        vertices[index] = x;
        vertices[index + 1] = y;
        vertices[index + 2] = 0.0;

        indices[(i * (segmentCount ~/ 4) + j) * 3] = 0;
        indices[(i * (segmentCount ~/ 4) + j) * 3 + 1] = index ~/ verticesPerSegment;
        indices[(i * (segmentCount ~/ 4) + j) * 3 + 2] = index ~/ verticesPerSegment + 1;
      }
    }
    indices[segmentCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }
}

class Geometry {
  List<double> vertices;
  List<int> indices;
  Geometry(this.vertices, this.indices);
}