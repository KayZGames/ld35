library shared;
import 'dart:async';
import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
part 'package:ld35/src/shared/geometry_generator.dart';
part 'src/shared/components.dart';
part 'src/shared/managers.dart';
//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';
part 'src/shared/systems/spawner.dart';

const int segmentCount = 60;
const String playerTag = 'player';
const double playerRadius = 20.0;
// initial shape is circle
const double playerArea = playerRadius * playerRadius * PI;
const double maxSpeed = 2500.0;