import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';

import '../main.dart';

Widget particles(BuildContext context) {
  return CircularParticle(
    key: UniqueKey(),
    awayRadius: 5,
    numberOfParticles: 50,
    speedOfParticles: 0.7,
    height: mq.height,
    width: mq.width,
    onTapAnimation: false,
    particleColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withAlpha(150)
        : Colors.black54,
    awayAnimationDuration: const Duration(milliseconds: 200),
    maxParticleSize: 3,
    isRandSize: true,
    isRandomColor: false,
    awayAnimationCurve: Curves.linear,
    connectDots: false,
  );
}
