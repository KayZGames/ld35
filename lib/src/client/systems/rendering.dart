part of client;

class PlayerRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Vertices> vm;
  Mapper<Size> sm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  int valuesPerItem = 3;

  WebGlViewProjectionMatrixManager vpmm;

  PlayerRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, Vertices, Size])) {
    attributes = [new Attrib('aPos', valuesPerItem)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var v = vm[entity];
    var s = sm[entity];

    var offset = index * v.vertices.length;
    var indicesOffset = index * v.indices.length;

    for (int i = 0; i < v.indices.length; i++) {
      indices[indicesOffset + i] = v.indices[i];
    }
    for (int i = 0; i < v.vertices.length; i += 3) {
      items[offset + i] = v.vertices[i] * s.radius + p.xyz.x;
      items[offset + i + 1] = v.vertices[i + 1] * s.radius + p.xyz.y;
      items[offset + i + 2] = v.vertices[i + 2] + p.xyz.z;
    }
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create3dViewProjectionMatrix().storage);

    bufferElements(attributes, items, indices);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    items = new Float32List(length * (segmentCount + 1) * valuesPerItem);
    indices = new Uint16List(length * segmentCount * valuesPerItem);
  }

  @override
  String get fShaderFile => 'PlayerRenderingSystem';

  @override
  String get vShaderFile => 'PlayerRenderingSystem';
}

class TunnelSegmentRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<TunnelSegment> tsm;
  TagManager tm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  int valuesPerItem = 9;
  int segmentsPerTunnelSegment = 64 * 2;

  WebGlViewProjectionMatrixManager vpmm;
  MusicPlayerSystem mps;

  TunnelSegmentRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, TunnelSegment])) {
    attributes = [new Attrib('aPos', 3), new Attrib('aLightDirection', 3), new Attrib('aNormal', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var ts = tsm[entity];
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];

    var offset = index * segmentsPerTunnelSegment * valuesPerItem;
    var indicesOffset = index * segmentsPerTunnelSegment * 3;

    for (var i = 0; i < segmentsPerTunnelSegment; i += 2) {
      var loopOffset = offset + i * valuesPerItem;
      items[loopOffset] = ts.segments[i * 2] * mps.beatFactor;
      items[loopOffset + 1] = ts.segments[i * 2 + 1] * mps.beatFactor;
      items[loopOffset + 2] = p.xyz.z;

      items[loopOffset + 3] = items[loopOffset] - playerPos.xyz.x;
      items[loopOffset + 4] = items[loopOffset + 1] - playerPos.xyz.y;
      items[loopOffset + 5] = items[loopOffset + 2] - playerPos.xyz.z;

      items[loopOffset + 6] = items[loopOffset];
      items[loopOffset + 7] = items[loopOffset + 1];
      items[loopOffset + 8] = 0.0;

      items[loopOffset + 9] = ts.segments[i * 2 + 2] * mps.beatFactor;
      items[loopOffset + 10] = ts.segments[i * 2 + 3] * mps.beatFactor;
      items[loopOffset + 11] = items[loopOffset + 2] + ts.length;

      items[loopOffset + 12] = items[loopOffset + 9] - playerPos.xyz.x;
      items[loopOffset + 13] = items[loopOffset + 10] - playerPos.xyz.y;
      items[loopOffset + 14] = items[loopOffset + 11] - playerPos.xyz.z;

      items[loopOffset + 15] = items[loopOffset + 9];
      items[loopOffset + 16] = items[loopOffset + 10];
      items[loopOffset + 17] = 0.0;
    }

    for (var i = 0; i < segmentsPerTunnelSegment; i += 2) {
      var loopOffset = offset ~/ valuesPerItem + i;
      var loopIndicesOffset = indicesOffset + i * 3;

      indices[loopIndicesOffset] = loopOffset;
      indices[loopIndicesOffset + 1] = loopOffset + 1;
      indices[loopIndicesOffset + 2] = loopOffset + 2;

      indices[loopIndicesOffset + 3] = loopOffset + 2;
      indices[loopIndicesOffset + 4] = loopOffset + 1;
      indices[loopIndicesOffset + 5] = loopOffset + 3;
    }
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 4] =
        offset ~/ valuesPerItem;
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 3] =
        offset ~/ valuesPerItem;
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 1] =
        offset ~/ valuesPerItem + 1;
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create3dViewProjectionMatrix().storage);
    gl.uniform1f(gl.getUniformLocation(program, 'uTime'), time);
    gl.uniform1f(gl.getUniformLocation(program, 'uBeatMod'), (mps.beatFactor - 1.0) * 5.0 + 1.0);

    bufferElements(attributes, items, indices);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    items = new Float32List(length * segmentsPerTunnelSegment * valuesPerItem);
    indices = new Uint16List(length * segmentsPerTunnelSegment * 3);
  }

  @override
  String get vShaderFile => 'TunnelSegmentRenderingSystem';

  @override
  String get fShaderFile => 'TunnelSegmentRenderingSystem';
}

class ObstacleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Obstacle> om;
  Mapper<Color> cm;
  TagManager tm;

  Position playerPos;

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  int valuesPerItem = 10;
  int segmentsPerObstacle = segmentCount * 2;

  WebGlViewProjectionMatrixManager vpmm;
  MusicPlayerSystem mps;

  ObstacleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Obstacle, Position, Color])) {
    attributes = [new Attrib('aPos', 3), new Attrib('aColor', 4), new Attrib('aLightDirection', 3)];
  }

  @override
  void begin() {
    var playerEntity = tm.getEntity(playerTag);
    playerPos = pm[playerEntity];
  }

  @override
  void processEntity(int index, Entity entity) {
    var o = om[entity];
    var p = pm[entity];
    var c = cm[entity];
    var type = o.type;

    final itemCount = valuesPerItem * segmentsPerObstacle;
    var offset = index * itemCount;
    var indicesOffset = index * segmentsPerObstacle * 3;
    for (int i = 0; i < segmentsPerObstacle; i += 2) {
      final loopOffset = offset + i * valuesPerItem;
      final loopIndicesOffset = indicesOffset + i * 3;

      createShapeBorderVertex(i, loopOffset, p, c, type);

      createBorderVertex(loopOffset, p, c, i);

      indices[loopIndicesOffset] = loopOffset ~/ valuesPerItem;
      indices[loopIndicesOffset + 1] = loopOffset ~/ valuesPerItem + 1;
      indices[loopIndicesOffset + 2] = loopOffset ~/ valuesPerItem + 2;
      indices[loopIndicesOffset + 3] = loopOffset ~/ valuesPerItem + 2;
      indices[loopIndicesOffset + 4] = loopOffset ~/ valuesPerItem + 1;
      indices[loopIndicesOffset + 5] = loopOffset ~/ valuesPerItem + 3;
    }
    indices[indicesOffset + segmentsPerObstacle * 3 - 1] =
        offset ~/ valuesPerItem + 1;
    indices[indicesOffset + segmentsPerObstacle * 3 - 3] =
        offset ~/ valuesPerItem;
    indices[indicesOffset + segmentsPerObstacle * 3 - 4] =
        offset ~/ valuesPerItem;
  }

  void createShapeBorderVertex(
      int segment, int loopOffset, Position p, Color c, int type) {
    var x = 0.0, y = 0.0;
    switch (type) {
      case 0:
        final angle = -PI / 4 + 2 * PI * segment / segmentsPerObstacle;
        x = cos(angle);
        y = sin(angle);
        break;
      case 1:
        var i = segment ~/ (segmentsPerObstacle ~/ 4);
        var j = segment % (segmentsPerObstacle ~/ 4);
        switch (i) {
          case 0:
            x = 1.0;
            y = -1.0 + 2 * (j / (segmentsPerObstacle ~/ 4));
            break;
          case 1:
            x = 1.0 - 2 * (j / (segmentsPerObstacle ~/ 4));
            y = 1.0;
            break;
          case 2:
            x = -1.0;
            y = 1.0 - 2 * (j / (segmentsPerObstacle ~/ 4));
            break;
          case 3:
            x = -1.0 + 2 * (j / (segmentsPerObstacle ~/ 4));
            y = -1.0;
            break;
        }
        break;
      case 2:
        var i = segment ~/ (segmentsPerObstacle ~/ 3);
        var j = segment % (segmentsPerObstacle ~/ 3);
        final angle = -PI / 6 + 2 * PI * i / 3;
        final nextAngle = -PI / 6 + 2 * PI * (i + 1) / 3;
        x = cos(angle) +
            ((cos(nextAngle) - cos(angle)) * (j / (segmentsPerObstacle ~/ 3)));
        y = sin(angle) +
            ((sin(nextAngle) - sin(angle)) * (j / (segmentsPerObstacle ~/ 3)));
        break;
    }
    if (type == -1) {
      items[loopOffset] = p.xyz.x;
      items[loopOffset + 1] = p.xyz.y;
    } else {
      items[loopOffset] = p.xyz.x +
          x * GeometryGenerator.shapeRadiusCalculators[type](playerArea);
      items[loopOffset + 1] = p.xyz.y +
          y * GeometryGenerator.shapeRadiusCalculators[type](playerArea);
    }
    items[loopOffset + 2] = p.xyz.z;
    items[loopOffset + 3] = c.r;
    items[loopOffset + 4] = c.g;
    items[loopOffset + 5] = c.b;
    items[loopOffset + 6] =
        max(0.0, min(0.7, (p.xyz.z - playerPos.xyz.z + 100.0) / 100.0));
    items[loopOffset + 7] = items[loopOffset] - playerPos.xyz.x;
    items[loopOffset + 8] = items[loopOffset + 1] - playerPos.xyz.y;
    items[loopOffset + 9] = items[loopOffset + 2] - playerPos.xyz.z;
  }

  void createBorderVertex(int loopOffset, Position p, Color c, int segment) {
    var x, y;
    var i = segment ~/ (segmentsPerObstacle ~/ 4);
    var j = segment % (segmentsPerObstacle ~/ 4);
    switch (i) {
      case 0:
        x = 1.0;
        y = -1.0 + 2 * (j / (segmentsPerObstacle ~/ 4));
        break;
      case 1:
        x = 1.0 - 2 * (j / (segmentsPerObstacle ~/ 4));
        y = 1.0;
        break;
      case 2:
        x = -1.0;
        y = 1.0 - 2 * (j / (segmentsPerObstacle ~/ 4));
        break;
      case 3:
        x = -1.0 + 2 * (j / (segmentsPerObstacle ~/ 4));
        y = -1.0;
        break;
    }
    items[loopOffset + 10] = p.xyz.x + x * playerRadius * 2;
    items[loopOffset + 11] = p.xyz.y + y * playerRadius * 2;
    items[loopOffset + 12] = p.xyz.z;
    items[loopOffset + 13] = c.r;
    items[loopOffset + 14] = c.g;
    items[loopOffset + 15] = c.b;
    items[loopOffset + 16] =
        max(0.0, min(0.9, (p.xyz.z - playerPos.xyz.z + 100.0) / 100.0));
    items[loopOffset + 17] = items[loopOffset + 10] - playerPos.xyz.x;
    items[loopOffset + 18] = items[loopOffset + 11] - playerPos.xyz.y;
    items[loopOffset + 19] = items[loopOffset + 12] - playerPos.xyz.z;
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create3dViewProjectionMatrix().storage);

    bufferElements(attributes, items, indices);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    items = new Float32List(length * segmentsPerObstacle * valuesPerItem);
    indices = new Uint16List(length * segmentsPerObstacle * 3);
  }

  @override
  String get vShaderFile => 'ObstacleRenderingSystem';

  @override
  String get fShaderFile => 'ObstacleRenderingSystem';
}

class DistanceTraveledRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  GameStateManager gsm;
  CanvasElement canvasHud;

  DistanceTraveledRenderingSystem(this.canvasHud)
      : super(Aspect.getAspectForAllOf([Controller, Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var ctx = canvasHud.context2D;
    var distance = (p.xyz.z ~/ 1000).toString();
    ctx
      ..font = '20px Verdana'
      ..fillText('Obstacles:', gsm.width - 200.0, 20.0)
      ..fillText(distance, gsm.width - ctx.measureText(distance).width, 20.0);
  }
}
