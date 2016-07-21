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

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  int valuesPerItem = 3;
  int segmentsPerTunnelSegment = 64 * 2;

  WebGlViewProjectionMatrixManager vpmm;

  TunnelSegmentRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, TunnelSegment])) {
    attributes = [new Attrib('aPos', valuesPerItem)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var ts = tsm[entity];

    var offset = index * segmentsPerTunnelSegment * valuesPerItem;
    var indicesOffset = index * segmentsPerTunnelSegment * 3;

    for (var i = 0; i < segmentsPerTunnelSegment; i += 2) {
      var angle = 2 * PI * i / segmentsPerTunnelSegment;
      var loopOffset = offset + i * 3;
      items[loopOffset] = sin(angle) * ts.radius;
      items[loopOffset + 1] = cos(angle) * ts.radius;
      items[loopOffset + 2] = p.xyz.z;

      items[loopOffset + 3] = items[loopOffset];
      items[loopOffset + 4] = items[loopOffset + 1];
      items[loopOffset + 5] = items[loopOffset + 2] + ts.length;
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

  Float32List items;
  Uint16List indices;
  List<Attrib> attributes;

  int valuesPerItem = 3;
  int segmentsPerObstacle = segmentCount * 2;

  WebGlViewProjectionMatrixManager vpmm;

  ObstacleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Obstacle, Position])) {
    attributes = [new Attrib('aPos', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var o = om[entity];
    var p = pm[entity];
    var type = o.type;

    final itemCount = valuesPerItem * segmentsPerObstacle;
    var offset = index * itemCount;
    var indicesOffset = index * segmentsPerObstacle * 3;
    for (int i = 0; i < segmentsPerObstacle; i += 2) {
      final loopOffset = offset + i * valuesPerItem;
      final loopIndicesOffset = indicesOffset + i * 3;

      createShapeBorderVertex(i, loopOffset, p, type);

      createBorderVertex(loopOffset, p, i);

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

  void createShapeBorderVertex(int segment, int loopOffset, Position p, int type) {
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
    }
    items[loopOffset] = p.xyz.x + x * playerRadius;
    items[loopOffset + 1] = p.xyz.y + y * playerRadius;
    items[loopOffset + 2] = p.xyz.z;
  }

  void createBorderVertex(int loopOffset, Position p, int segment) {
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
    items[loopOffset + 3] = p.xyz.x + x * playerRadius * 2;
    items[loopOffset + 4] = p.xyz.y + y * playerRadius * 2;
    items[loopOffset + 5] = p.xyz.z;

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
