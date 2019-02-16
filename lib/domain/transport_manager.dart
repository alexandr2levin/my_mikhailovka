import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/data/bus62_api.dart';
import 'package:my_mikhailovka/domain/transport_objects_helper.dart';

class TransportManager {
  TransportManager(this._bus62Api);

  static const city = "ryazan";

  final Bus62Api _bus62Api;

  List<TransportRoute> _routes;
  List<Station> _stations;

  Future<List<TransportRoute>> routes() async {
    while(_routes == null) {
      try {
        _routes = (await _bus62Api.allRoutes(city))
            .map((rawRoute) {
              return TransportRoute(rawRoute.id, rawRoute.name, rawRoute.type,
                  rawRoute.number, rawRoute.fromStationId, rawRoute.toStationId);
            })
            .toList(growable: false);
      } on SocketException catch (e) {
        print('retry because of "${e.toString()}"');
        await Future.delayed(Duration(seconds: 1));
      }
    }

    return _routes;
  }

  Future<List<Station>> stations() async {
    while(_stations == null) {
      try {
        _stations = (await _bus62Api.stations(city))
            .map((rawStation) {
              return Station(rawStation.id, rawStation.name, rawStation.latLng);
            })
            .toList(growable: false);
      } on SocketException catch (e) {
        print('retry because of "${e.toString()}"');
        await Future.delayed(Duration(seconds: 1));
      }
    }

    return _stations;
  }

  Future<List<TransportRoute>> routesFor(List<RouteFilter> filters) async {
    return (await routes())
        .where((route) {
          return filters.any((filter) {
            return route.number == filter.number && route.type == filter.type;
          });
        })
        .toList(growable: false);
  }

  Stream<List<StationForecast>> observeStationForecasts(int stationId) async* {
    while(true) {
      try {
        var routes = await this.routes();
        var rawForecasts = await _bus62Api.stationForecasts(city, stationId);

        yield rawForecasts
            .map((rawForecast) {
              var route = routes
                  .firstWhere((rawRoute) => rawForecast.routeId == rawRoute.id);
              return StationForecast(
                route.id,
                route.name,
                route.number,
                route.type,
                Duration(seconds: rawForecast.tillArrival),
              );
            })
            .toList();
        await Future.delayed(Duration(seconds: 5));
      } on SocketException catch (e) {
        print('retry because of "${e.toString()}"');
        yield null;
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Stream<List<TransportObject>> observeTransportObjects(List<int> routesIds) async* {
    var routes = await this.routes();
    var objectsHelper = TransportObjectsHelper(routes);
    while(true) {
      try {
        var rawVehicleAnimations = await _bus62Api.vehicleAnimations(
            city, routesIds, objectsHelper.maxAnimationKey
        );

        yield objectsHelper.process(rawVehicleAnimations);
        await Future.delayed(Duration(seconds: 10));
      } on SocketException catch (e) {
        print('retry because of "${e.toString()}"');
        yield null;
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

}

class RouteFilter {
  RouteFilter(this.type, this.number);

  final RouteType type;
  final String number;
}

class TransportObject {
  TransportObject(this.objectId, this.lastUpdateTime, this.routeType,
      this.routeNumber, this.animation);

  final int objectId;
  final RouteType routeType;
  final String routeNumber;
  final DateTime lastUpdateTime;
  final TransportAnimation animation;

}

class TransportAnimation {
  TransportAnimation(this.animationKey, this.keyframes);

  final int animationKey;
  final List<TransportAnimationKeyframe> keyframes;

}

class TransportAnimationKeyframe {
  TransportAnimationKeyframe(this.duration, this.latLng, this.rotation);

  final Duration duration;
  final LatLng latLng;
  // rotation in rad
  final double rotation;
}

class TransportRoute {
  TransportRoute(this.id, this.name, this.type, this.number, this.fromStationId,
      this.toStationId);

  final int id;
  final String name;
  final RouteType type;
  final String number;
  final int fromStationId;
  final int toStationId;
}

class StationForecast {
  StationForecast(this.routeId, this.routeName, this.routeNumber, this.routeType, this.tillArrival);

  final int routeId;
  final String routeName;
  final String routeNumber;
  final RouteType routeType;
  final Duration tillArrival;

}

class Station {
  Station(this.id, this.name, this.latLng);

  final int id;
  final String name;
  final LatLng latLng;
}