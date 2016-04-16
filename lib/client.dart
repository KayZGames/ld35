library client;

import 'dart:html' hide Player, Timeline;
export 'dart:html' hide Player, Timeline;
import 'package:ld35/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'dart:web_gl';
import 'dart:typed_data';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;

  Game() : super.noAssets('ld35', '#game', 800, 600, webgl: true) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '16px Verdana';
    Tween.combinedAttributesLimit = (segmentCount + 1) * 3;
  }

  void createEntities() {
     addEntity([new Position(0.0, 0.0, 0.0), new Vertices.square()]);
  }

  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new TweeningSystem(),
        new InputHandlingSystem(hudCanvas),
        new ShapeShiftingSystem(),
        new WebGlCanvasCleaningSystem(ctx),
        new CanvasCleaningSystem(hudCanvas),
        new Abc(ctx),
        new FpsRenderingSystem(hudCtx, fillStyle: 'white'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }
}
