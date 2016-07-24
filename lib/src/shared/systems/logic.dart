part of shared;

class ShapeShiftingSystem extends EntityProcessingSystem {
  Mapper<Vertices> vm;
  Mapper<Size> sm;

  bool shapeshift = false;
  int maxShapes = 3;
  int currentShape = 0;

  ShapeShiftingSystem() : super(Aspect.getAspectForAllOf([Vertices, Size]));

  @override
  void processEntity(Entity entity) {
    var v = vm[entity];
    var s = sm[entity];

    new Tween.to(v, Vertices.tweenVertices, 1.0)
      ..targetValues =
          GeometryGenerator.shapeGenerators[currentShape]().vertices
      ..easing = Elastic.OUT
      ..start(tweenManager);

    s.radius = GeometryGenerator.shapeRadiusCalculators[currentShape](s.area);

    shapeshift = false;
  }

  set nextShape(int nextShape) {
    currentShape = nextShape;
    shapeshift = true;
  }

  @override
  bool checkProcessing() => shapeshift;
}

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    p.xyz += v.xyz * world.delta;
  }
}

class PlayerAccelerationSystem extends EntityProcessingSystem {
  Mapper<Velocity> vm;
  Mapper<Position> pm;
  double startSpeed;

  PlayerAccelerationSystem(this.startSpeed)
      : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    v.xyz.z = min(maxSpeed, max(startSpeed, 100.0 + p.xyz.z / 100.0));
  }
}

class DespawningSystem extends EntitySystem {
  TagManager tm;
  Mapper<Position> pm;

  DespawningSystem() : super(Aspect.getAspectForAllOf([Position]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    entities.forEach((entity) {
      var p = pm[entity];
      if (p.xyz.z + 500.0 < playerPos.xyz.z) {
        entity.deleteFromWorld();
      }
    });
  }

  @override
  bool checkProcessing() => true;
}

class ObstacleCollisionDetectionSystem extends EntityProcessingSystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Obstacle> om;
  ShapeShiftingSystem sss;
  GameStateManager gsm;
  int lastShape;

  ObstacleCollisionDetectionSystem()
      : super(Aspect.getAspectForAllOf([Obstacle, Position]));

  @override
  void processEntity(Entity entity) {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var p = pm[entity];

    var distance = playerPos.xyz.z - p.xyz.z;

    if (distance <= 0.0 && distance > -500.0) {
      lastShape = sss.currentShape;
    } else if (lastShape != null &&
        distance > 0.0 &&
        distance < 500.0 &&
        p.xyz.xy == playerPos.xyz.xy) {
      if (lastShape != om[entity].type) {
        gsm.gameOver(playerPos.xyz.z ~/ 1000 - 1);
      }
      lastShape = null;
    }
  }
}
