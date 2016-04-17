part of client;

class PlayerRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Vertices> vm;
  Mapper<Size> sm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attribsutes;

  int valuesPerItem = 3;

  WebGlViewProjectionMatrixManager vpmm;

  PlayerRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, Vertices, Size])) {
    attribsutes = [new Attrib('aPos', valuesPerItem)];
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
      items[offset + i] = v.vertices[i] * s.radius;
      items[offset + i + 1] = v.vertices[i + 1] * s.radius;
      items[offset + i + 2] = v.vertices[i + 2] * s.radius;
    }
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create3dViewProjectionMatrix().storage);

    bufferElements(attribsutes, items, indices);
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
  List<Attrib> attribsutes;

  int valuesPerItem = 3;
  int segmentsPerTunnelSegment = 64 * 2;

  WebGlViewProjectionMatrixManager vpmm;

  TunnelSegmentRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, TunnelSegment])) {
    attribsutes = [new Attrib('aPos', valuesPerItem)];
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
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 4] = offset ~/ valuesPerItem;
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 3] = offset ~/ valuesPerItem;
    indices[indicesOffset + segmentsPerTunnelSegment * 3 - 1] = offset ~/ valuesPerItem + 1;
  }

  bool done = false;
  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create3dViewProjectionMatrix().storage);

    if (!done) {
      print(items);
      print(items.length ~/ 3);
      print(indices);
      done = true;
    }

    bufferElements(attribsutes, items, indices);
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
