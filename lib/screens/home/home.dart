import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_mikhailovka/app_localizations.dart';
import 'package:my_mikhailovka/domain/mikhailovka/mikhailovka_manager.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';
import 'package:my_mikhailovka/screens/home/forecasts.dart';
import 'package:my_mikhailovka/screens/home/transport_map.dart';
import 'package:rubber/rubber.dart';

class HomePage extends StatefulWidget {
  final TransportManager transportManager;

  HomePage(this.transportManager, {Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  MikhailovkaManager _mikhailovkaManager;

  ScrollController _scrollController = ScrollController();
  RubberAnimationController _controller;

  var _currentTab = 0;
  int _selectedRouteId;

  @override
  void initState() {
    super.initState();
    _mikhailovkaManager = MikhailovkaManager(widget.transportManager);

    final SpringDescription _mySpringDescription = SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 500.0,
      ratio: 1.0,
    );

    _controller = RubberAnimationController(
      vsync: this,
      upperBoundValue: AnimationControllerValue(percentage: 0.9),
      halfBoundValue: AnimationControllerValue(percentage: 0.4),
      lowerBoundValue: AnimationControllerValue(pixel: 54.0 + 78.0),
      duration: Duration(milliseconds: 200),
      springDescription: _mySpringDescription
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).homeTitle),
      ),
      body: RubberBottomSheet(
        lowerLayer: TransportMap(_mikhailovkaManager, _selectedRouteId),
        upperLayer: Forecasts(
          mikhailovkaManager: _mikhailovkaManager,
          currentTabChanged: (currentTab) {
            setState(() {
              _currentTab = currentTab;
            });
          },
          forecastClicked: (forecast) {
            setState(() {
              _selectedRouteId = forecast.routeId;
            });
          },
          scrollController: _scrollController,
        ),
        scrollController: _scrollController,
        animationController: _controller,
      ),
    );
  }

}
