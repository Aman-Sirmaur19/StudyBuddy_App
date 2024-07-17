import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/my_themes.dart';

Widget particles(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return CircularParticle(
    key: UniqueKey(),
    awayRadius: 5,
    numberOfParticles: 50,
    speedOfParticles: 0.7,
    height: mq.height,
    width: mq.width,
    onTapAnimation: false,
    particleColor:
        themeProvider.isDarkMode ? Colors.white.withAlpha(150) : Colors.black54,
    awayAnimationDuration: const Duration(milliseconds: 200),
    maxParticleSize: 3,
    isRandSize: true,
    isRandomColor: false,
    awayAnimationCurve: Curves.linear,
    connectDots: false,
  );
}
