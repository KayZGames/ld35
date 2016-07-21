import 'package:ld35/client.dart';

void main() {
  querySelector('#loading').style.display = 'none';
  (querySelector('#startGame') as ButtonElement)
    ..style.display = 'inline-block'
    ..focus()
    ..onClick.listen((_) {
      querySelector('#story').style.opacity = '0.0';
      querySelector('#game').style
        ..opacity = '1.0'
        ..display = 'block';
      querySelector('#hud').style
        ..opacity = '1.0'
        ..display = 'block';
      new Timer(new Duration(seconds: 1),
          () => querySelector('#story').style.display = 'none');

      var game = new Game()..start();
      game.onGameOver().then((score) {
        game.stop();
        querySelector('#lastscore').text = '$score';
        if (int.parse(querySelector('#highscore').text) < score) {
          querySelector('#highscore').text = '$score';
        }
        querySelector('#story').style
          ..opacity = '1.0'
          ..display = 'block';
        querySelector('#game').style
          ..opacity = '0.0'
          ..display = 'none';
        querySelector('#hud').style
          ..opacity = '0.0'
          ..display = 'none';
      });
    });
}
