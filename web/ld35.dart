import 'package:ld35/client.dart';
void main() {
  querySelector('#loading').style.display = 'none';
  (querySelector('#startGame') as ButtonElement).style.display = 'inline-block';
  querySelector('#startGame').onClick.listen((_) {
    querySelector('#story').style.opacity = '0.0';
    querySelector('#game').style.opacity = '1.0';
    querySelector('#hud').style.opacity = '1.0';
    new Timer(new Duration(seconds: 1), () => querySelector('#story').style.display = 'none');
    new Game().start();
  });
}
