part of shared;

class Position extends Component {
  Vector3 xyz;
  Position(double x, double y, double z) : xyz = new Vector3(x, y, z);
}

class Vertices extends Component {
  List<Vector3> vertices;
  List<int> indices;

  Vertices.circle() {
    var square = GeometryGenerator.createCircle();
    this.vertices = square.vertices;
    this.indices = square.indices;
  }

  Vertices.square() {
    var square = GeometryGenerator.createSquare();
    this.vertices = square.vertices;
    this.indices = square.indices;
  }
}