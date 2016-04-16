part of shared;

class GameStateManager extends Manager {
  int width, height;
}

class WebGlViewProjectionMatrixManager extends Manager {
  Mapper<Position> pm;
  GameStateManager gsm;
  TagManager tm;

  Matrix4 create2dViewProjectionMatrix() {
    var playerEntity = tm.getEntity(playerTag);
    var p = pm[playerEntity];
    return create2dViewProjectionMatrixForPosition(p.xyz.x, p.xyz.y);
  }

  Matrix4 create2dViewProjectionMatrixForPosition(double px, double py) {
    var playerEntity = tm.getEntity(playerTag);
    var angle = 0.0;
    var viewMatrix = new Matrix4.identity();
    var projMatrix = new Matrix4.identity();
    setViewMatrix(
        viewMatrix,
        new Vector3(400.0 + 100 * sin(angle), 550.0, -150.0),
        new Vector3(400.0, 200.0, 150.0),
        new Vector3(0.0, -1.0, 0.0));
    setPerspectiveMatrix(projMatrix, PI / 2, 4 / 3, 1.0, 1000.0);
//    var threedViewProjextionMatrix = projMatrix * viewMatrix;
    var twodOrthographicMatrix = new Matrix4.identity();
    var width = 800;
    var height = 600;
    var factor = gsm.width / gsm.height;
    if (factor > 4 / 3) {
      width = height * factor;
    } else {
      height = width / factor;
    }
    setOrthographicMatrix(twodOrthographicMatrix, px - width / 2,
        px + width / 2, py - height / 2, py + height / 2, 250.0, -250.0);

//  return threedViewProjextionMatrix * camera.three + twodOrthographicMatrix * camera.two;
    return twodOrthographicMatrix; // * rotationMatrix;
  }
}