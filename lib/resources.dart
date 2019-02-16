
import 'package:flutter/material.dart';
import 'package:my_mikhailovka/data/bus62_api.dart';

class Resources {
  static Color routeTypeColor(RouteType routeType) {
    switch(routeType) {
      case RouteType.bus:
        return Colors.red;
      case RouteType.minibus:
        return Colors.amber[800];
      case RouteType.trolleybus:
        return Colors.blue;
    }
  }
}