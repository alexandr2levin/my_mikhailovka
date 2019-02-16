
import 'package:my_mikhailovka/data/bus62_api.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';

class TransportObjectsHelper {
  TransportObjectsHelper(this._routes);

  
  final List<TransportRoute> _routes;
  
  var maxAnimationKey = 0;
  var _aliveObjectsMap = <int, TransportObject> {};

  List<TransportObject> process(List<RawVehicleAnimation> animations) {
    var now = DateTime.now();
    for(var anim in animations) {
      if(maxAnimationKey < anim.animationKey) {
        maxAnimationKey = anim.animationKey;
      }

      var route = _routes.firstWhere((route) => route.id == anim.routeId);

      var keyframes = <TransportAnimationKeyframe>[];
      if(!_aliveObjectsMap.containsKey(anim.objectId)) {
        // use initial location for first appearance
        keyframes.add(
            TransportAnimationKeyframe(
              Duration(milliseconds: 0),
              anim.latLng,
              anim.rotation,
            )
        );
      }
      keyframes.addAll(
          anim.keyframes
              .map((rawKeyframe) {
                return TransportAnimationKeyframe(
                  rawKeyframe.duration,
                  rawKeyframe.latLng,
                  rawKeyframe.rotation,
                );
              })
              .toList()
      );

      _aliveObjectsMap[anim.objectId] = TransportObject(
        anim.objectId,
        now,
        route.type,
        route.number,
        TransportAnimation(
          anim.animationKey,
          keyframes,
        )
      );
    }

    _removeOutdatedObjects();

    return _aliveObjectsMap.values.toList();
  }

  void _removeOutdatedObjects() {
    var now = DateTime.now();
    for(var entry in _aliveObjectsMap.entries.toList()) {
      var sinceLastUpdate = now.difference(entry.value.lastUpdateTime);
      if(sinceLastUpdate.inSeconds > 20) {
        _aliveObjectsMap.remove(entry.key);
      }
    }
  }

}