part of shared;

class TunnelSegmentSpawner extends VoidEntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  int lastSegment = 0;
  final double tunnelLength = 100.0;

  @override
  void processSystem() {
    world.createAndAddEntity([new Position(0.0, 0.0, tunnelLength * lastSegment), new TunnelSegment(200.0, tunnelLength)]);
    lastSegment++;
  }

  @override
  bool checkProcessing() {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    return p.xyz.z ~/ 100 > lastSegment - 5;
  }


}

