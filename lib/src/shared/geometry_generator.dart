part of shared;

typedef Geometry ShapeGenerator();
typedef double ShapeRadiusCalculator(double area);

class GeometryGenerator {
  static List<ShapeGenerator> shapeGenerators = [
    createCircle,
    createSquare,
    createTriangle
  ];
  static List<ShapeRadiusCalculator> shapeRadiusCalculators = [
    getCircleRadius,
    getSquareRadius,
    getTriangleRadius
  ];

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
      final angle = -PI / 4 + 2 * PI * i / segmentCount;
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
        final angle =
            -PI / 4 + 2 * PI * (i * (segmentCount ~/ 4) + j) / segmentCount;
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
        indices[(i * (segmentCount ~/ 4) + j) * 3 + 1] =
            index ~/ verticesPerSegment;
        indices[(i * (segmentCount ~/ 4) + j) * 3 + 2] =
            index ~/ verticesPerSegment + 1;
      }
    }
    indices[segmentCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }

  static Geometry createTriangle() {
    final verticesPerSegment = 3;
    final verticeCount = verticesPerSegment * (segmentCount + 1);
    final vertices = new List(verticeCount);
    final indices = new List(segmentCount * verticesPerSegment);
    vertices[0] = 0.0;
    vertices[1] = 0.0;
    vertices[2] = 0.0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < segmentCount ~/ 3; j++) {
        final index = verticesPerSegment * (i * (segmentCount ~/ 3) + j + 1);
        final angle = -PI / 6 + 2 * PI * i / 3;
        final nextAngle = -PI / 6 + 2 * PI * (i + 1) / 3;
        var x = cos(angle) +
            ((cos(nextAngle) - cos(angle)) * (j / (segmentCount ~/ 3)));
        var y = sin(angle) +
            ((sin(nextAngle) - sin(angle)) * (j / (segmentCount ~/ 3)));
        vertices[index] = x;
        vertices[index + 1] = y;
        vertices[index + 2] = 0.0;

        indices[(i * (segmentCount ~/ 3) + j) * 3] = 0;
        indices[(i * (segmentCount ~/ 3) + j) * 3 + 1] =
            index ~/ verticesPerSegment;
        indices[(i * (segmentCount ~/ 3) + j) * 3 + 2] =
            index ~/ verticesPerSegment + 1;
      }
    }
    indices[segmentCount * 3 - 1] = 1;
    return new Geometry(vertices, indices);
  }

  static double getCircleRadius(double area) => sqrt(area / PI);
  static double getSquareRadius(double area) => sqrt(area) / 2;
  static double getTriangleRadius(double area) {
    var a = sqrt(4 * area / sqrt(3));
    return a * sqrt(3) / 3;
  }
}

class Geometry {
  List<double> vertices;
  List<int> indices;
  Geometry(this.vertices, this.indices);
}
