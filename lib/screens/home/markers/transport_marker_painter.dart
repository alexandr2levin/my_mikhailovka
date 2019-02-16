
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:my_mikhailovka/math_extra.dart';

class TransportMarkerPainter extends CustomPainter {
  TransportMarkerPainter(this.rotation, this.number, this.color);

  // rotation in rads
  final double rotation;
  final String number;
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
    
    var rotationStartDecart = center + offsetFrom(polarToDecart(radius, rotation - pi/4.0));
    var rotationDecart = center + offsetFrom(polarToDecart(radius * 1.5, rotation));
    var rotationEndDecart = center + offsetFrom(polarToDecart(radius, rotation + pi/4.0));

    var trianglePath = Path();
    trianglePath.moveTo(rotationStartDecart.dx, rotationStartDecart.dy);
    trianglePath.lineTo(rotationDecart.dx, rotationDecart.dy);
    trianglePath.lineTo(rotationEndDecart.dx, rotationEndDecart.dy);
    canvas.drawPath(trianglePath, paint);

    canvas.drawCircle(center, radius, paint);

    TextSpan span = new TextSpan(
        style: new TextStyle(
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
        text: number
    );
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(TransportMarkerPainter oldDelegate) {
    return oldDelegate.color != color
        || oldDelegate.number != number
        || oldDelegate.rotation != rotation;
  }

}