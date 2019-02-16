
import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/domain/mikhailovka/route_elements.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';

// contains meta info for Mikhailovka and provides it
class MikhailovkaInfo {
  static final _mikhailovkaRoutesInfoDescriptions = [
    MikhailovkaRouteInfoDescription(
      routeId: 257, // ..113 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в сторону пос. Божатково)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(66), // Вокзальная (в центр)
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 227, // ..103 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(66), // Вокзальная (в центр)
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 225, // ..104 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(266), // Поворот на вокзальную (в центр); этой станции нет в bus62, т.ч. берем ближайшую
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 255, // ..126 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(266), // Поворот на вокзальную (в центр); этой станции нет в bus62, т.ч. берем ближайшую
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 229, // ..117 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(266), // Поворот на вокзальную (в центр); этой станции нет в bus62, т.ч. берем ближайшую
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 269, // ..147 (~от Михайловки)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(268), // Рязань-2 (на Московское)
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 15, // А-13 (от Божатково)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(129), // пл. Победы (в центр)
        StationRouteElementDescription(45), // Ленина (в сторону пл. Театральной)
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 14, // А-13 (от Куриза)
      elementsDescriptions: [
        StationRouteElementDescription(306), // Пивзавод (в сторону пос. Божатково)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(99), // пл. Победы (на Московское)
        StationRouteElementDescription(221), // пл. Ленина (в сторону Победы)
      ].reversed.toList(),
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 113, // А-57 (от Божатково)
      elementsDescriptions: [
        StationRouteElementDescription(318), // Пивзавод (в центр)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(129), // пл. Победы (в центр)
        StationRouteElementDescription(45), // Ленина (в сторону пл. Театральной)
      ],
    ),
    MikhailovkaRouteInfoDescription(
      routeId: 112, // А-57 (от Новосёлов)
      elementsDescriptions: [
        StationRouteElementDescription(306), // Пивзавод (в сторону пос. Божатково)
        PointRouteElementDescription(LatLng(54.631389, 39.702915)),
        StationRouteElementDescription(99), // пл. Победы (на Московское)
        StationRouteElementDescription(221), // пл. Ленина (в сторону Победы)
      ].reversed.toList(),
    ),
  ];

  static MikhailovkaRouteInfo info(List<Station> stations, int routeId) {
    var description = _mikhailovkaRoutesInfoDescriptions
        .firstWhere((desc) => desc.routeId == routeId);

    var foundStations = <Station>[];
    var elements = description.elementsDescriptions
        .map((elementDescription) {
          switch(elementDescription.runtimeType) {
            case StationRouteElementDescription:
              var casted = elementDescription as StationRouteElementDescription;
              var station = stations.firstWhere((station) {
                return station.id == casted.stationId;
              });
              foundStations.add(station);
              return StationRouteElement(station);
            case PointRouteElementDescription:
              var casted = elementDescription as PointRouteElementDescription;
              return PointRouteElement(casted.latLng);
            default:
              throw 'no case for type "$elementDescription"';
          }
        })
        .toList();

    return MikhailovkaRouteInfo(
      routeId: description.routeId,
      stations: foundStations,
      elements: elements,
    );
  }

}

class MikhailovkaRouteInfo {
  MikhailovkaRouteInfo({this.routeId, this.stations, this.elements});

  final int routeId;
  final List<Station> stations;
  final List<RouteElement> elements;
}

class MikhailovkaRouteInfoDescription {
  MikhailovkaRouteInfoDescription({this.routeId, this.elementsDescriptions});

  final int routeId;
  final List<RouteElementDescription> elementsDescriptions;
}

class RouteElementDescription {

}

class StationRouteElementDescription extends RouteElementDescription {
  StationRouteElementDescription(this.stationId);

  final int stationId;
}

class PointRouteElementDescription extends RouteElementDescription {
  PointRouteElementDescription(this.latLng);

  final LatLng latLng;
}