part of client;

class Abc extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Vertices> vm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attribsutes;

  int valuesPerItem = 3;

  Abc(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Vertices])) {
    attribsutes = [new Attrib('aPos', valuesPerItem)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    var offset = index * v.vertices.length;
    var indicesOffset = index * v.indices.length;

    for (int i = 0; i < v.indices.length; i++) {
      indices[indicesOffset + i] = v.indices[i];
    }
    for (int i = 0; i < v.vertices.length; i += 3) {
      items[offset + i] = v.vertices[i] * 0.5;
      items[offset + i + 1] = v.vertices[i + 1] * 0.5;
      items[offset + i + 2] = v.vertices[i + 2] * 0.5;
    }
  }

  @override
  void render(int length) {
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
