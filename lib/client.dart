library client;

import 'dart:html';
export 'dart:html';
import 'package:ld35/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'dart:web_gl';
import 'dart:typed_data';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  Game() : super.noAssets('ld35', '#game', 800, 600, webgl: true) {
    Tween.combinedAttributesLimit = (segmentCount + 1) * 3;

    world.addManager(new GameStateManager());
    world.addManager(new WebGlViewProjectionMatrixManager());
    world.addManager(new TagManager());

    handleResize(window.innerWidth, window.innerHeight);
    window.onResize
        .listen((_) => handleResize(window.innerWidth, window.innerHeight));
  }

  @override
  void createEntities() {
    var tm = world.getManager(TagManager) as TagManager;
    var player = addEntity([
      new Position(0.0, 0.0, 0.0),
      new Velocity(0.0, 0.0, 4000.0),
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
        new TunnelSegmentSpawner(),
        new ObstacleSpawner(),
        new TweeningSystem(),
        new InputHandlingSystem(),
        new MovementSystem(),
        new PlayerAccelerationSystem(),
        new ShapeShiftingSystem(),
        new WebGlCanvasCleaningSystem(ctx),
        new ObstacleRenderingSystem(ctx),
        new TunnelSegmentRenderingSystem(ctx),
        new PlayerRenderingSystem(ctx),
        new DespawningSystem(),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(600, height);
    canvas.width = width;
    canvas.height = height;
    canvas.style.width = '${width}px';
    canvas.style.height = '${height}px';
    (ctx as RenderingContext).viewport(0, 0, width, height);
    (world.getManager(GameStateManager) as GameStateManager)
      ..width = width
      ..height = height;
  }
}
