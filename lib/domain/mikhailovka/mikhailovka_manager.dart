
import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/data/bus62_api.dart';
import 'package:my_mikhailovka/domain/mikhailovka/mikhailovka_info_descriptions.dart';
import 'package:my_mikhailovka/domain/mikhailovka/route_elements.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';

class MikhailovkaManager {
  MikhailovkaManager(this._transportManager);

  static final _mikhailovkaRouteFilters = [
    RouteFilter(RouteType.bus, "133"), // до Вокальная
    RouteFilter(RouteType.bus, "103"), // до Вокальная
    RouteFilter(RouteType.bus, "104"), // до Около моста
    RouteFilter(RouteType.bus, "117"), // до Около моста
    RouteFilter(RouteType.bus, "126"), // до Около моста
    RouteFilter(RouteType.bus, "147"), // до Рязань 2
    RouteFilter(RouteType.bus, "13"), // до Норм
    RouteFilter(RouteType.bus, "57"), // до Норм
  ];
  
  static final stationLeninaId = 221;
  static final stationPivzavodId = 318;

  final TransportManager _transportManager;

  List<TransportRoute> _mikhailovkaRoutes;

  Future<List<TransportRoute>> mikhailovkaRoutes() async {
    if(_mikhailovkaRoutes == null) {
      _mikhailovkaRoutes = await _transportManager.routesFor(_mikhailovkaRouteFilters);
      print('mikhailovka routes count "${_mikhailovkaRoutes.length}"');
    }
    return _mikhailovkaRoutes;
  }

  Stream<List<TransportObject>> observeTransportObjects() async* {
    var mikhailovkaRoutesIds = (await mikhailovkaRoutes())
        .map((route) => route.id).toList();

    yield* _transportManager.observeTransportObjects(mikhailovkaRoutesIds);
  }

  Stream<List<StationForecast>> observeStationForecasts(int stationId) async* {
    var mikhailovkaRoutesIds = (await mikhailovkaRoutes())
        .map((route) => route.id).toList();

    yield* _transportManager.observeStationForecasts(stationId)
        .map((stationForecasts) {
          if(stationForecasts == null) return null;
          return stationForecasts
              .where((forecast) => mikhailovkaRoutesIds.contains(forecast.routeId))
              .toList();
        });
  }

  Stream<List<StationForecast>> observePivzavodStationForecasts() async* {
    yield* observeStationForecasts(stationPivzavodId);
  }

  Stream<List<StationForecast>> observeLeninaStationForecasts() async*  {
    yield* observeStationForecasts(stationLeninaId);
  }

  Future<MikhailovkaRouteInfo> mikhailovkaRouteInfo(int routeId) async {
    if(routeId == null) return null;
    var stations = await _transportManager.stations();
    return MikhailovkaInfo.info(stations, routeId);
  }

  Future<Station> pivzavodStation() async {
    var stations = await _transportManager.stations();
    return stations.firstWhere((station) {
      return station.id == stationPivzavodId;
    });
  }

  Future<Station> leninaStation() async {
    var stations = await _transportManager.stations();
    return stations.firstWhere((station) {
      return station.id == stationLeninaId;
    });
  }

}