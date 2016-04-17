part of shared;

class TunnelSegmentSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  int lastSegment = 0;
  final double tunnelLength = 100.0;

  @override
  void processSystem() {
    world.createAndAddEntity([
      new Position(0.0, 0.0, tunnelLength * lastSegment),
      new TunnelSegment(200.0, tunnelLength)
    ]);
    lastSegment++;
  }

  @override
  bool checkProcessing() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    return p.xyz.z ~/ 100 > lastSegment - 100;
  }
}

class ObstacleSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  int lastObstacle = 1;

  @override
  void processSystem() {
    for (int i = -2; i < 3; i++) {
      for (int j = -2; j < 3; j++) {
        world.createAndAddEntity([
          new Position(i * playerRadius * 4, j * playerRadius * 4,
              lastObstacle * 1000.0),
          new Obstacle(random.nextInt(2))
        ]);
      }
    }
    lastObstacle++;
  }

  @override
  bool checkProcessing() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    return p.xyz.z ~/ 1000 > lastObstacle - 10;
  }
}
