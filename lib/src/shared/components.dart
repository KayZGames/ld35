part of shared;

class Position extends Component {
  Vector3 xyz;
  Position(double x, double y, double z) : xyz = new Vector3(x, y, z);
}

class Velocity extends Component {
  Vector3 xyz;
  Velocity(double x, double y, double z) : xyz = new Vector3(x, y, z);
}

class Size extends Component {
  double radius, area;
  Size(this.area, this.radius);
}

class TunnelSegment extends Component {
  double radius, length;
  TunnelSegment(this.radius, this.length);
}

class Vertices extends Component implements Tweenable {
  static final int tweenVertices = 0;

  List<double> vertices;
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

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    if (tweenType == tweenVertices) {
      for (int i = 0; i < vertices.length; i++) {
        returnValues[i] = vertices[i];
      }
      return vertices.length;
    }
    return 0;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    if (tweenType == tweenVertices) {
      for (int i = 0; i < vertices.length; i++) {
        vertices[i] = newValues[i];
      }
    }
  }
}