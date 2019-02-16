
import 'package:flutter/material.dart';
import 'dart:math';

class StationMarkerPainter extends CustomPainter {
  StationMarkerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 5.0;

    var center = Offset(size.width / 2.0, size.height / 2.0);
    var radius = size.width / 2;


    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(StationMarkerPainter oldDelegate) {
    return oldDelegate.color != color;
  }

}