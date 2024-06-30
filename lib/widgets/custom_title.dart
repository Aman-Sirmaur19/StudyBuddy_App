import 'package:flutter/material.dart';

Widget customTitle(double? fontSize, double? letterSpacing) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Study',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            color: const Color.fromRGBO(255, 196, 58, 1.0),
          )),
      Text('Buddy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            color: const Color.fromRGBO(241, 68, 79, 1.0),
          )),
    ],
  );
}
