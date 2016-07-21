part of shared;

class GameStateManager extends Manager {
  int width, height;
  var _completer = new Completer<int>();

  Future<int> onGameOver() {
    return _completer.future;
  }

  void gameOver(int score) {
    _completer.complete(score);
  }
}

class WebGlViewProjectionMatrixManager extends Manager {
  Mapper<Position> pm;
  GameStateManager gsm;
  TagManager tm;

  Matrix4 create3dViewProjectionMatrix() {
    var playerEntity = tm.getEntity(playerTag);
    var p = pm[playerEntity];
    return create3dViewProjectionMatrixForPosition(p.xyz);
  }

  Matrix4 create3dViewProjectionMatrixForPosition(Vector3 position) {
    var factor = gsm.width / gsm.height;
    var viewMatrix = new Matrix4.identity();
    var projMatrix = new Matrix4.identity();
    setViewMatrix(viewMatrix, new Vector3(position.x + 25.0, position.y - 25.0, position.z - 100.0),
        new Vector3(position.x + 10.0, position.y - 10.0, position.z + 10.0), new Vector3(0.0, -1.0, 0.0));
    setPerspectiveMatrix(projMatrix, PI / 2, factor, 1.0, 10000.0);
    var threedViewProjextionMatrix = projMatrix * viewMatrix;

    return threedViewProjextionMatrix;
  }
}
