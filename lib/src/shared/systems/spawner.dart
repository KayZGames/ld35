part of shared;

class TunnelSegmentSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  int lastSegment = 0;
  final double tunnelLength = 500.0;
  int segmentsPerTunnelSegment = 64 * 2;
  int lastSegmentType = 0;
  final int segmentTypes = 2;

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    while (p.xyz.z ~/ tunnelLength > lastSegment - tunnelLength) {
      world.createAndAddEntity([
        new Position(0.0, 0.0, tunnelLength * lastSegment),
        new TunnelSegment(tunnelLength, createTunnelSegments(200.0))
      ]);
      lastSegment++;
    }
  }

  Float32List createTunnelSegments(double radius) {
    var nextSegmentType = (random.nextDouble() < 0.8) ? lastSegmentType : (lastSegmentType +1) % segmentTypes;
    var segmentType = [lastSegmentType, nextSegmentType];
    lastSegmentType = nextSegmentType;
    var segments = new Float32List(segmentsPerTunnelSegment * 2);

    for (int segment = 0; segment < segmentsPerTunnelSegment; segment += 1) {
      switch (segmentType[segment % 2]) {
        case 0:
          var angle = 2 * PI * segment / segmentsPerTunnelSegment;
          segments[segment * 2] = cos(angle) * radius;
          segments[segment * 2 + 1] = sin(angle) * radius;
          break;
        case 1:
          var x = 0.0, y = 0.0;
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
          segments[segment * 2] = x * radius;
          segments[segment * 2 + 1] = y * radius;
      }
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
    for (int i = -2; i < 3; i++) {
      for (int j = -2; j < 3; j++) {
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
    return x.abs() == 2 || y.abs() == 2;
  }

  @override
  bool checkProcessing() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    return p.xyz.z ~/ 1000 > lastObstacle - 10;
  }
}
