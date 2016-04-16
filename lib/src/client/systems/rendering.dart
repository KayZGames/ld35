part of client;

class Abc extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Vertices> vm;

  Float32List items;
  Uint16List indices;
  List<Attrib> attribsutes;

  int valuesPerItem = 3;

  Abc(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position, Vertices])) {
    attribsutes = [new Attrib('aPos', 3)];
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    var offset = index * valuesPerItem * v.vertices.length;
    var indicesOffset = index * v.indices.length;

    for (int i = 0; i < v.indices.length; i++) {
      indices[indicesOffset + i] = v.indices[i] + offset;
    }
    for (int i = 0; i < v.vertices.length; i++) {
      var v3 = v.vertices[i];
      items[offset + i * valuesPerItem] = v3.x * 0.5;
      items[offset + i * valuesPerItem + 1] = v3.y * 0.5;
      items[offset + i * valuesPerItem + 2] = v3.z * 0.5;
    }
  }

  @override
  void render(int length) {
    bufferElements(attribsutes, items, indices);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    items = new Float32List(length * (verticeCount + 1) * valuesPerItem);
    indices = new Uint16List(length * verticeCount * 3);
  }

  @override
  String get fShaderFile => 'PlayerRenderingSystem';
  @override
  String get vShaderFile => 'PlayerRenderingSystem';
}
