part of client;

class InputHandlingSystem extends GenericInputHandlingSystem {
  ShapeShiftingSystem sss;
  Mapper<Position> pm;
  Mapper<Controller> cm;

  Point<double> position = new Point<double>(0.0, 0.0);

  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Controller]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    if (up) {
      p.xyz.y = playerRadius * -4;
    } else if (down) {
      p.xyz.y = playerRadius * 4;
    } else {
      p.xyz.y = 0.0;
    }
    if (left) {
      p.xyz.x = playerRadius * -4;
    } else if (right) {
      p.xyz.x = playerRadius * 4;
    } else {
      p.xyz.x = 0.0;
    }
  }

  @override
  void handleInput(KeyboardEvent event, bool pressed) {
    super.handleInput(event, pressed);
    if (pressed) {
      if (event.keyCode >= KeyCode.ONE &&
          event.keyCode < KeyCode.ONE + sss.maxShapes) {
        sss.nextShape = event.keyCode - KeyCode.ONE;
      } else if (event.keyCode >= KeyCode.NUM_ONE &&
          event.keyCode < KeyCode.NUM_ONE + sss.maxShapes) {
        sss.nextShape = event.keyCode - KeyCode.NUM_ONE;
      }
    }
  }
}
