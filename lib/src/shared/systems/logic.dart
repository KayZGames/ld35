part of shared;

class ShapeShiftingSystem extends EntityProcessingSystem {
  Mapper<Vertices> vm;
  bool shapeshift = false;
  int maxShapes = 2;
  int currentShape = 0;

  ShapeShiftingSystem() : super(Aspect.getAspectForAllOf([Vertices]));

  @override
  void processEntity(Entity entity) {
    var v = vm[entity];

    new Tween.to(v, Vertices.tweenVertices, 1.0)
      ..targetValues = GeometryGenerator.shapeGenerators[currentShape]().vertices
      ..easing = Elastic.OUT
      ..start(tweenManager);

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
