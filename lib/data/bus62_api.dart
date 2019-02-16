import 'dart:math';

import 'package:http/http.dart';
import 'dart:convert';

import 'package:latlong/latlong.dart';
import 'package:vector_math/vector_math.dart';

class Bus62Api {

  static const endpoint = 'http://api.bus62.ru';

  Future<List<RawTransportRoute>> allRoutes(String city) async {
    var response = await get('$endpoint/api9/getAllRoutes.php?city=$city');

    if(response.statusCode == 200) {
      var jsonList = (json.decode(response.body) as List<dynamic>);
      return jsonList
          .map((jsonElement) {
            return RawTransportRoute.fromJson(jsonElement);
          })
          .toList();
    } else {
      throw 'Failed to get station forecasts, body "${response.body}"';
    }
  }

  Future<List<RawStation>> stations(String city) async {
    var response = await get('$endpoint/api9/getAllStations.php?city=$city');
    // replace invalid header provided by server
    response.headers["content-type"] = "text/plain;charset=UTF-8";

    if(response.statusCode == 200) {
      var jsonList = (json.decode(response.body) as List<dynamic>);
      return jsonList
          .map((jsonElement) {
            return RawStation.fromJson(jsonElement);
          })
          .toList();
    } else {
      throw 'Failed to get station forecasts, body "${response.body}"';
    }
  }

  Future<List<RawStationForecast>> stationForecasts(String city, int stationId) async {
    var response = await get('$endpoint/api9/getStationForecasts.php'
        '?sid=$stationId'
        '&city=$city');

    if(response.statusCode == 200) {
      var jsonList = (json.decode(response.body) as List<dynamic>);
      return jsonList
          .map((jsonElement) { 
            return RawStationForecast.fromJson(jsonElement);
          })
          .toList();
    } else {
      throw 'Failed to get station forecasts, body "${response.body}"';
    }
  }

  // lastMaxAnimId allows to filter already received animation on server-side
  Future<List<RawVehicleAnimation>> vehicleAnimations(String city, List<int> routeIds, int lastMaxAnimId) async {
    var routeIdsJoined = routeIds.join(",");
    var response = await get('$endpoint/api9/getVehicleAnimations.php'
        '?city=$city'
        '&rids=$routeIdsJoined'
        '&curk=$lastMaxAnimId');

    if(response.statusCode == 200) {
      var jsonList = (json.decode(response.body) as List<dynamic>);
      return jsonList
          .map((jsonElement) {
            return RawVehicleAnimation.fromJson(jsonElement);
          })
          .toList();
    } else {
      throw 'Failed to get station forecasts, body "${response.body}"';
    }
  }

}

class RawVehicleAnimation {
  RawVehicleAnimation(this.objectId, this.animationKey, this.latLng, this.rotation, this.routeId, this.keyframes);

  final int objectId;
  final int animationKey;
  final int routeId;
  final LatLng latLng;
  final double rotation;
  final List<RawKeyframe> keyframes;

  factory RawVehicleAnimation.fromJson(Map<String, dynamic> json) {
    return RawVehicleAnimation(
      int.parse(json["id"]),
      int.parse(json["anim_key"]),
      LatLng(_latOrLngFromString(json["lat"]), _latOrLngFromString(json["lng"])),
      // I don't know why, but we need to subtract 90 degrees from this rotation
      parseRotation(json["dir"]) - (pi / 2),
      int.parse(json["rid"]),
      (json["anim_points"] as List<dynamic>)
        .map((keyframeJson) {
          return RawKeyframe.fromJson(keyframeJson);
        })
        .toList(),
    );
  }

}

class RawKeyframe {
  RawKeyframe(this.duration, this.latLng, this.rotation);

  final Duration duration;
  final LatLng latLng;
  final double rotation;

  factory RawKeyframe.fromJson(Map<String, dynamic> json) {
    return RawKeyframe(
      // convert percent to duration
      // 10 seconds is constant animation duration
      Duration(
        milliseconds: (20.0 * 10.0 * int.parse(json["percent"])).round()
      ),
      LatLng(_latOrLngFromString(json["lat"]), _latOrLngFromString(json["lon"])),
      parseRotation(json["dir"]),
    );
  }
}

class RawTransportRoute {
  RawTransportRoute(this.id, this.name, this.type, this.number, this.fromStationId,
      this.toStationId);

  final int id;
  final String name;
  final RouteType type;
  final String number;
  final int fromStationId;
  final int toStationId;

  factory RawTransportRoute.fromJson(Map<String, dynamic> json) {
    RouteType routeType;

    var rawRouteType = json['type'];
    switch(rawRouteType) {
      case 'Т':
        routeType = RouteType.trolleybus;
        break;
      case 'М':
        routeType = RouteType.minibus;
        break;
      case 'А':
        routeType = RouteType.bus;
        break;
      default:
        throw 'no for raw route type "$rawRouteType"';
    }

    return RawTransportRoute(
      int.parse(json["id"]),
      json["name"],
      routeType,
      json["number"],
      int.parse(json["from_station_id"]),
      int.parse(json["to_station_id"])
    );
  }
}

class RawStationForecast {
  final int routeId;
  final int tillArrival;
  final String currentStation;
  final String lastStation;

  RawStationForecast(this.routeId, this.tillArrival, this.currentStation, this.lastStation);

  factory RawStationForecast.fromJson(Map<String, dynamic> json) {
    return RawStationForecast(
        int.parse(json['rid']),
        int.parse(json['arrt']),
        json['where'],
        json['last']
    );
  }

}

class RawStation {
  RawStation(this.id, this.name, this.latLng);

  final int id;
  final String name;
  final LatLng latLng;

  factory RawStation.fromJson(Map<String, dynamic> json) {
    return RawStation(
      int.parse(json['id']),
      json['name'],
      LatLng(_latOrLngFromString(json["lat0"]), _latOrLngFromString(json["lon0"])),
    );
  }
}

enum RouteType {
  trolleybus,
  minibus,
  bus
}

double parseRotation(String rotation) {
  return radians(double.parse(rotation));
}

double _latOrLngFromString(String latString) {
  return double.parse('${latString.substring(0, 2)}.${latString.substring(2)}');
}