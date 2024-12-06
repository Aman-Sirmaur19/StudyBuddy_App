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
            color: Colors.amber,
          )),
      Text('Buddy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            color: Colors.red,
          )),
    ],
  );
}
