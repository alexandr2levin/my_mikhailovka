import 'package:flutter/material.dart';

import 'package:my_mikhailovka/app.dart';
import 'package:my_mikhailovka/data/bus62_api.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';

void main() {
  var bus62Api = Bus62Api();
  var transportManger = TransportManager(bus62Api);

  runApp(App(transportManger));
}