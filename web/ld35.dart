import 'package:ld35/client.dart';

Game game;

Future<Null> main() async {
  game = await new Game().start();
  game.stop();
  querySelector('#loading').style.display = 'none';
  (querySelector('#startGame') as ButtonElement)
    ..style.display = 'inline-block';
  querySelector('#startGame').onClick.listen((_) {
    if (game.isStopped) {
      startGame();
    }
  });
  querySelector('body').onKeyDown.listen((event) {
    if (game.isStopped && event.keyCode == KeyCode.ENTER) {
      startGame();
    }
  });
}

Future<Null> startGame() async {
  game = await new Game().start();
  game.pause();
  game.startSpeed = double.parse(
      (querySelector('input[type=radio][name=speed]:checked')
              as RadioButtonInputElement)
          .value);
  querySelector('#storyContainer').style..opacity = '0.0';
  querySelector('body').style.cursor = 'none';
  querySelector('#game').style.opacity = '1.0';
  querySelector('#hud').style.opacity = '1.0';

  await new Future.delayed(new Duration(seconds: 1));
  game.resume();
  querySelector('#storyContainer').style.display = 'none';
  game.onGameOver().then((score) {
    game.stop();
    querySelector('#lastscore').text = '$score';
    if (int.parse(querySelector('#highscore').text) < score) {
      querySelector('#highscore').text = '$score';
    }
    querySelector('#storyContainer').style
      ..opacity = '1.0'
      ..display = 'flex'
      ..cursor = 'inherit';
    querySelector('#game').style.opacity = '0.1';
    querySelector('#hud').style.opacity = '0.1';
    querySelector('body').style.cursor = 'inherit';
  });
}
