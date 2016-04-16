part of client;

class InputHandlingSystem extends VoidEntitySystem {
  CanvasElement canvas;
  ShapeShiftingSystem sss;
  num deltaY = 0.0;

  InputHandlingSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseWheel.listen(handleMouseWheel);
  }

  @override
  void processSystem() {
    if (deltaY > 0) {
      sss.nextShape();
    } else if (deltaY < 0) {
      sss.previousShape();
    }
    deltaY = 0.0;
  }

  void handleMouseWheel(WheelEvent event) {
    deltaY = event.deltaY;
    event.preventDefault();
  }
}
