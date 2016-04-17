part of client;

class InputHandlingSystem extends VoidEntitySystem {
  ShapeShiftingSystem sss;
  GameStateManager gsm;
  TagManager tm;
  Mapper<Position> pm;

  CanvasElement canvas;
  num deltaY = 0.0;
  Point<double> position = new Point<double>(0.0, 0.0);

  InputHandlingSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseWheel.listen(handleMouseWheel);
    canvas.onMouseMove.listen(handleMouseMove);
  }

  @override
  void processSystem() {
    if (deltaY > 0) {
      sss.nextShape();
    } else if (deltaY < 0) {
      sss.previousShape();
    }
    deltaY = 0.0;

    var player = tm.getEntity(playerTag);
    var p = pm[player];
    p.xyz.xy = new Vector2(position.x, position.y);
  }

  void handleMouseWheel(WheelEvent event) {
    deltaY = event.deltaY;
    event.preventDefault();
  }

  void handleMouseMove(MouseEvent event) {
    position = event.offset - new Point(gsm.width / 2, gsm.height / 2);
  }
}
