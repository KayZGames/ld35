library client;

import 'dart:html';
export 'dart:html';
import 'dart:web_audio';
import 'package:ld35/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'dart:web_gl';
import 'dart:typed_data';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';
part 'src/client/systems/audio.dart';

class Game extends GameBase {
  CanvasElement canvasHud;
  double _startSpeed = 0.0;
  int gamepadIndex;

  Game()
      : super('ld35', '#game', 800, 600,
            webgl: true,
            musicName: '8-Bit-Mayhem',
            bodyDefsName: null,
            spriteSheetName: null) {
    Tween.combinedAttributesLimit = (segmentCount + 1) * 3;

    world.addManager(new GameStateManager());
    world.addManager(new WebGlViewProjectionMatrixManager());
    world.addManager(new TagManager());

    canvasHud = querySelector('#hud');

    handleResize(window.innerWidth, window.innerHeight);
    window.onResize
        .listen((_) => handleResize(window.innerWidth, window.innerHeight));
  }

  @override
  void createEntities() {
    var tm = world.getManager(TagManager) as TagManager;
    var player = addEntity([
      new Position(0.0, 0.0, -1000.0),
      new Velocity(0.0, 0.0, _startSpeed),
      new Vertices.circle(),
      new Size(PI * playerRadius * playerRadius, playerRadius),
      new Controller()
    ]);
    tm.register(player, playerTag);
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new MusicPlayerSystem(music),
        new TunnelSegmentSpawner(),
        new ObstacleSpawner(),
        new TweeningSystem(),
        new InputHandlingSystem(() => gamepadIndex),
        new MovementSystem(),
        new PlayerAccelerationSystem(_startSpeed),
        new ShapeShiftingSystem(),
        new WebGlCanvasCleaningSystem(ctx),
        new ObstacleRenderingSystem(ctx),
        new TunnelSegmentRenderingSystem(ctx),
        new PlayerRenderingSystem(ctx),
        new DespawningSystem(),
        new CanvasCleaningSystem(canvasHud),
        new DistanceTraveledRenderingSystem(canvasHud)
      ],
      GameBase.physics: [
        new ObstacleCollisionDetectionSystem(),
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(600, height);
    resizeCanvas(canvas, width, height);
    resizeCanvas(canvasHud, width, height);
    (ctx as RenderingContext).viewport(0, 0, width, height);
    (world.getManager(GameStateManager) as GameStateManager)
      ..width = width
      ..height = height;
  }

  void resizeCanvas(CanvasElement canvas, int width, int height) {
    canvas.width = width;
    canvas.height = height;
    canvas.style.width = '${width}px';
    canvas.style.height = '${height}px';
  }

  Future<int> onGameOver() {
    var gsm = world.getManager(GameStateManager) as GameStateManager;
    return gsm.onGameOver();
  }

  set startSpeed(double value) {
    _startSpeed = value;
    (world.getSystem(PlayerAccelerationSystem) as PlayerAccelerationSystem)
        .startSpeed = value;
  }
}
