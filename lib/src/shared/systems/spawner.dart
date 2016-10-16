part of shared;

class TunnelSegmentSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  double totalLength = -3000.0;
  int segmentsPerTunnelSegment = 64 * 2;
  int lastSegmentType = 0;
  double lastRotAngle = 0.0;
  final int segmentTypes = 3;

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    while (p.xyz.z > totalLength - 50000.0) {
      var tunnelLength = 250.0 + random.nextDouble() * 1250.0;
      world.createAndAddEntity([
        new Position(0.0, 0.0, totalLength),
        new TunnelSegment(tunnelLength, createTunnelSegments(175.0 * 175.0 * PI))
      ]);
      totalLength += tunnelLength;
    }
  }

  Float32List createTunnelSegments(double area) {
    var nextSegmentType = (random.nextDouble() < 0.8)
        ? lastSegmentType
        : random.nextInt(segmentTypes);
    var segmentType = [lastSegmentType, nextSegmentType];
    var radius = [
      GeometryGenerator.shapeRadiusCalculators[lastSegmentType](area),
      GeometryGenerator.shapeRadiusCalculators[nextSegmentType](area)
    ];
    var nextRotAngle = 0.0;
    if (totalLength > 25000.0) {
      nextRotAngle = lastRotAngle -PI / 8 + PI * random.nextDouble() / 4;
    }
    var rotAngles = [lastRotAngle, nextRotAngle];
    lastSegmentType = nextSegmentType;
    lastRotAngle = nextRotAngle;
    var segments = new Float32List(segmentsPerTunnelSegment * 2);

    for (int segment = 0; segment < segmentsPerTunnelSegment; segment += 1) {
      var x = 0.0, y = 0.0;
      switch (segmentType[segment % 2]) {
        case 0:
          var segmentMod = (segment - segment % 2) - segmentsPerTunnelSegment ~/ 8;
          final angle = 2 * PI * segmentMod / segmentsPerTunnelSegment;
          x = cos(angle);
          y = sin(angle);
          break;
        case 1:
          var i = segment ~/ (segmentsPerTunnelSegment ~/ 4);
          var j = segment % (segmentsPerTunnelSegment ~/ 4);
          switch (i) {
            case 0:
              x = 1.0;
              y = -1.0 + 2 * (j / (segmentsPerTunnelSegment ~/ 4));
              break;
            case 1:
              x = 1.0 - 2 * (j / (segmentsPerTunnelSegment ~/ 4));
              y = 1.0;
              break;
            case 2:
              x = -1.0;
              y = 1.0 - 2 * (j / (segmentsPerTunnelSegment ~/ 4));
              break;
            case 3:
              x = -1.0 + 2 * (j / (segmentsPerTunnelSegment ~/ 4));
              y = -1.0;
              break;
          }
          break;
        case 2:
          var segmentMod = segment + 15 * segmentsPerTunnelSegment ~/ 16;
          var i = segmentMod ~/ (segmentsPerTunnelSegment ~/ 3);
          var j = segmentMod % (segmentsPerTunnelSegment ~/ 3);
          final angle = -PI / 6 + 2 * PI * i / 3;
          final nextAngle = -PI / 6 + 2 * PI * (i + 1) / 3;
          x = cos(angle) +
              ((cos(nextAngle) - cos(angle)) *
                  (j / (segmentsPerTunnelSegment ~/ 3)));
          y = sin(angle) +
              ((sin(nextAngle) - sin(angle)) *
                  (j / (segmentsPerTunnelSegment ~/ 3)));
          break;
      }
      var cs = cos(rotAngles[segment % 2]);
      var sn = sin(rotAngles[segment % 2]);

      var rotX = x * cs - y * sn;
      var rotY = x * sn + y * cs;

      segments[segment * 2] = rotX * radius[segment % 2];
      segments[segment * 2 + 1] = rotY * radius[segment % 2];
    }

    return segments;
  }
}

class ObstacleSpawner extends VoidEntitySystem {
  ShapeShiftingSystem sss;
  TagManager tm;
  Mapper<Position> pm;
  int lastObstacle = 1;

  @override
  void processSystem() {
    var r = lastObstacle % 2 * 0.5 + 0.3;
    var g = lastObstacle % 2 * 0.5 + 0.3;
    var b = lastObstacle % 2 * 0.5 + 0.3;
    var obstacles = max(1 + random.nextInt(3), 9 - (lastObstacle ~/ 7));
    var shapes = min(sss.maxShapes, 2 + lastObstacle ~/ 23);
    var obstacleList =
        new List.generate(9, (index) => index < obstacles ? true : false);
    obstacleList.shuffle(random);
    for (int i = -3; i < 4; i++) {
      for (int j = -3; j < 4; j++) {
        var obstacleType = isBorder(i, j)
            ? -1
            : obstacleList.removeLast() ? random.nextInt(shapes) : -1;
        world.createAndAddEntity([
          new Position(i * playerRadius * 4, j * playerRadius * 4,
              lastObstacle * 1000.0),
          new Obstacle(obstacleType),
          new Color(r, g, b)
        ]);
      }
    }
    lastObstacle++;
  }

  bool isBorder(int x, int y) {
    return x.abs() >= 2 || y.abs() >= 2;
  }

  @override
  bool checkProcessing() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    return p.xyz.z ~/ 1000 > lastObstacle - 10;
  }
}
