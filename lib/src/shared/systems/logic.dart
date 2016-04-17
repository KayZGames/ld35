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
      ..targetValues = GeometryGenerator.shapeGenerators[currentShape]().vertices
      ..easing = Elastic.OUT
      ..start(tweenManager);

    s.radius = GeometryGenerator.shapeRadiusCalculators[currentShape](s.area);

    shapeshift = false;
  }


  void nextShape() {
    currentShape = (currentShape + 1) % maxShapes;
    shapeshift = true;
  }

  void previousShape() {
    currentShape = (currentShape - 1) % maxShapes;
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
