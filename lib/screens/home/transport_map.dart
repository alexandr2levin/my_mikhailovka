
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/data/bus62_api.dart';
import 'package:my_mikhailovka/domain/mikhailovka/mikhailovka_info_descriptions.dart';
import 'package:my_mikhailovka/domain/mikhailovka/mikhailovka_manager.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';
import 'package:my_mikhailovka/resources.dart';
import 'package:my_mikhailovka/screens/home/markers/station_marker_painter.dart';
import 'package:my_mikhailovka/screens/home/markers/transport_marker_painter.dart';
import 'package:my_mikhailovka/screens/home/transport_animator.dart';
import 'package:tuple/tuple.dart';

class TransportMap extends StatefulWidget {
  TransportMap(this._mikhailovkaManager, this.selectedRouteId);

  MikhailovkaManager _mikhailovkaManager;
  int selectedRouteId;

  @override
  State<StatefulWidget> createState() => _TransportMapState();
}

class _TransportMapState extends State<TransportMap> {

  MikhailovkaManager get _mikhailovkaManager => widget._mikhailovkaManager;
  TransportAnimator _transportAnimator;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _transportAnimator = TransportAnimator();

    _streamSubscription = _mikhailovkaManager.observeTransportObjects()
      .listen((transportObjects) {
        _transportAnimator.pushTransportObjects(transportObjects);
      });
  }

  @override
  void dispose() {
    _transportAnimator.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  Stream<Tuple2<MikhailovkaRouteInfo, List<AnimatedTransportObject>>> _mapInfo() async* {
    var mikhailovkaRouteInfo = await _mikhailovkaManager.mikhailovkaRouteInfo(widget.selectedRouteId);

    yield* _transportAnimator.animatedTransport()
        .map((transportObject) {
          return Tuple2(mikhailovkaRouteInfo, transportObject);
        });
  }

  @override
  Widget build(BuildContext context) {
    var tileLayerOptions = TileLayerOptions(
      urlTemplate: "https://api.tiles.mapbox.com/v4/"
          "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
      additionalOptions: {
        'accessToken': 'pk.eyJ1IjoiYWxleGFuZHJsZXZpbiIsImEiOiJjanJ1dXI3a2wweTBlNDNteWQ1ZDRtYWxkIn0.rP8L0Vk8Nq453rZKaT3y8w',
        'id': 'mapbox.streets',
      },
    );

    return StreamBuilder(
      stream: _mapInfo(),
      builder: (context, AsyncSnapshot<Tuple2<MikhailovkaRouteInfo, List<AnimatedTransportObject>>> snapshot) {
        var polylines = <Polyline>[];
        var markers = <Marker>[];
        if(snapshot.hasError) {
          print(snapshot.error.toString());
          return Center(
            child: Text("Ошибка!"),
          );
        }
        if(snapshot.hasData) {
          if(snapshot.data.item1 != null) {
            polylines.add(Polyline(
              points: snapshot.data.item1.elements.map((e) => e.latLng)
                  .toList(),
              strokeWidth: 4.0,
              color: Colors.blue.withOpacity(0.5),
            ));
            var stations = snapshot.data.item1.stations;
            markers.addAll(
              stations
                .map((station) {
                  var isFirst = stations.first == station;
                  return Marker(
                    width: 20.0,
                    height: 20.0,
                    point: station.latLng,
                    builder: (context) {
                          return CustomPaint(
                            painter: StationMarkerPainter(
                              isFirst ? Colors.black45 : Colors.blue.withOpacity(0.5),
                            ),
                          );
                        },
                      );
                    })
                  .toList(),
            );
          }
          if(snapshot.data.item2 != null) {
            markers.addAll(snapshot.data.item2
                .map((animatedObject) {
                  return Marker(
                    width: 25.0,
                    height: 25.0,
                    point: animatedObject.animatedLatLng,
                    builder: (context) {
                      return CustomPaint(
                        painter: TransportMarkerPainter(
                          animatedObject.animatedRotation.toDouble(),
                          animatedObject.object.routeNumber,
                          Resources.routeTypeColor(animatedObject.object.routeType),
                        ),
                      );
                    },
                  );
            })
                .toList(),
            );
          }
        }
        return FlutterMap(
          options: MapOptions(
            center: LatLng(54.637508, 39.711313),
            zoom: 11,
            maxZoom: 17,
            minZoom: 11,
          ),
          layers: [
            tileLayerOptions,
            MarkerLayerOptions(
              markers: markers,
            ),
            PolylineLayerOptions(
                polylines: polylines
            )
          ],
        );
      },
    );
  }

}