part of shared;

class TunnelSegmentSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  int lastSegment = 0;
  final double tunnelLength = 100.0;

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    while (p.xyz.z ~/ 100 > lastSegment - 100) {
      world.createAndAddEntity([
        new Position(0.0, 0.0, tunnelLength * lastSegment),
        new TunnelSegment(200.0, tunnelLength)
      ]);
      lastSegment++;
    }
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
    var obstacles = max(1, 9 - (lastObstacle ~/ 7));
    var shapes = min(sss.maxShapes, 2 + lastObstacle ~/ 23);
    var obstacleList = new List.generate(9, (index) => index < obstacles ? true : false);
    obstacleList.shuffle(random);
    for (int i = -2; i < 3; i++) {
      for (int j = -2; j < 3; j++) {
        var obstacleType =
            isBorder(i, j) ? -1 : obstacleList.removeLast() ? random.nextInt(shapes) : -1;
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
