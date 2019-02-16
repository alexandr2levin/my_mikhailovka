
import 'dart:math';

import 'dart:ui';

// r is radius, angle in radian
Point<double> polarToDecart(double r, double angle) {
  return Point(r*cos(angle), r*sin(angle));
}

Offset offsetFrom(Point<double> point) {
  return Offset(point.x, point.y);
}