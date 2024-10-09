import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Widget child;

  const GlassContainer({
    super.key,
    required this.color1,
    required this.color2,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Stack(
        children: [
          // blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            // child: Container(),
          ),
          // gradient effect
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color1.withOpacity(.15),
                      color2.withOpacity(.05),
                    ]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: color1.withOpacity(.13))),
          ),
          // child
          Center(child: child),
        ],
      ),
    );
  }
}
