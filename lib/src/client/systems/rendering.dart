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

  PlayerRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Vertices, Size])) {
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
        false, vpmm.create2dViewProjectionMatrix().storage);

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
