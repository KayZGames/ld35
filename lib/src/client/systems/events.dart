part of client;

typedef int GetGamePadIndex();

class InputHandlingSystem extends GenericInputHandlingSystem {
  ShapeShiftingSystem sss;
  Mapper<Position> pm;
  Mapper<Controller> cm;
  GameStateManager gsm;
  GetGamePadIndex getGamePadIndex;

  Point<double> position = new Point<double>(0.0, 0.0);

  InputHandlingSystem(this.getGamePadIndex)
      : super(Aspect.getAspectForAllOf([Controller]));

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

    if (null != getGamePadIndex()) {
      var gamepad = window.navigator.getGamepads()[getGamePadIndex()];
      if (gamepad.buttons[1].pressed) {
        sss.nextShape = 0;
      } else if (gamepad.buttons[2].pressed) {
        sss.nextShape = 1;
      } else if (gamepad.buttons[3].pressed) {
        sss.nextShape = 2;
      }
      p.xyz.x = gamepad.axes[0].abs() > 0.3
          ? gamepad.axes[0].sign * 4 * playerRadius
          : 0.0;
      p.xyz.y = gamepad.axes[1].abs() > 0.3
          ? gamepad.axes[1].sign * 4 * playerRadius
          : 0.0;
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
