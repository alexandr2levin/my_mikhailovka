
import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';

abstract class RouteElement {
  LatLng get latLng;
}

class StationRouteElement extends RouteElement {
  StationRouteElement(this.station);

  final Station station;

  @override
  LatLng get latLng => station.latLng;
}

class PointRouteElement extends RouteElement {
  PointRouteElement(this._latLng);

  final LatLng _latLng;

  @override
  LatLng get latLng => _latLng;

}