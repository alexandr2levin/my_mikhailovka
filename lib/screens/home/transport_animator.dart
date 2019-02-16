
import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:latlong/latlong.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';
import 'package:my_mikhailovka/math_extra.dart';
import 'package:vector_math/vector_math.dart';

class TransportAnimator {

  Ticker _ticker;
  TickerFuture _tickerFuture;
  var _animatedObjectsMap = <int, AnimatedTransportObject> {};
  
  var _animatedTransportStreamController = StreamController<List<AnimatedTransportObject>>();
  var _animatedTransportBroadcastStream;

  TransportAnimator() {
    _animatedTransportBroadcastStream = _animatedTransportStreamController.stream.asBroadcastStream();

    _ticker = Ticker((duration) {
      _updateAnimation();
    });
    _tickerFuture = _ticker.start();
  }

  void pushTransportObjects(List<TransportObject> objects) {
    var newAnimatedObjectsMap = <int, AnimatedTransportObject> {};
    for(var obj in objects) {
      if(_animatedObjectsMap.containsKey(obj.objectId)) {
        var existingObj = _animatedObjectsMap[obj.objectId];
        existingObj.pendingKeyframes = obj.animation.keyframes;
        newAnimatedObjectsMap[obj.objectId] = existingObj;
      } else {
        newAnimatedObjectsMap[obj.objectId] = AnimatedTransportObject(
          obj,
          pendingKeyframes: obj.animation.keyframes,
        );
      }
    }
    _animatedObjectsMap.clear();
    _animatedObjectsMap.addAll(newAnimatedObjectsMap);
  }

  void dispose() {
    _ticker.dispose();
    _animatedTransportStreamController.close();
  }

  void _updateAnimation() {
    var nowMillis = DateTime.now().millisecondsSinceEpoch;
    var animatedObjects = _animatedObjectsMap.values.toList();
    for(var animObj in animatedObjects) {
      if(animObj.currentKeyframe == null) {
        if(animObj.pendingKeyframes.isNotEmpty) {
          _toNextKeyframe(animObj);
        } else {
          if(animObj.animatedLatLng == null) {
            throw 'we can\'t continue and leave '
                'animObj "${animObj.object.objectId}" not initialized!';
          }
          continue;
        }
      }

      var prevKeyframe = animObj.previousKeyframe;
      var keyframe = animObj.currentKeyframe;

      var keyframeLifetime = nowMillis - animObj.keyframeStartMillis;
      double progress;
      if(keyframe.duration.inMilliseconds == 0) {
        progress = 1.0;
      } else {
        progress = keyframeLifetime / keyframe.duration.inMilliseconds;
      }

      if (progress >= 1.0) {
        progress = 1.0;
      }

      if(prevKeyframe != null) {
        animObj.animatedLatLng = animateBetweenTwoPoints(
            prevKeyframe.latLng, keyframe.latLng, progress
        );
        animObj.animatedRotation = animateRotation(
            prevKeyframe.rotation.toDouble(),
            keyframe.rotation.toDouble(),
            progress
        );
      } else {
        animObj.animatedLatLng = keyframe.latLng;
        animObj.animatedRotation = keyframe.rotation;
      }

      if(progress == 1.0) {
        if(animObj.pendingKeyframes.isNotEmpty) {
          _toNextKeyframe(animObj);
        }
      }
    }
    _animatedTransportStreamController.add(animatedObjects);
  }

  void _toNextKeyframe(AnimatedTransportObject animObj) {
    var nowMillis = DateTime.now().millisecondsSinceEpoch;
    var keyframe = animObj.pendingKeyframes.removeAt(0);

    animObj.keyframeStartMillis = nowMillis;
    animObj.previousKeyframe = animObj.currentKeyframe;
    animObj.currentKeyframe = keyframe;
  }

  LatLng animateBetweenTwoPoints(LatLng first, LatLng second, double progress) {
    var point1 = Vector2(first.latitude, first.longitude);
    var point2 = Vector2(second.latitude, second.longitude);

    var angle = atan2(point2.y - point1.y, point2.x - point1.x);
    var radius = point1.distanceTo(point2);

    var progressedRadius = radius * progress;
    var progressedPoint = polarToDecart(progressedRadius, angle);

    return LatLng(first.latitude + progressedPoint.x, first.longitude + progressedPoint.y);
  }

  // from and to is angles in rad
  double animateRotation(double from, double to, double progress) {
    double a = to - from;
    double diff = (a + pi) % (2 * pi) - pi;

    return from + (diff * progress);
  }

  Stream<List<AnimatedTransportObject>> animatedTransport() => _animatedTransportBroadcastStream;

}

class AnimatedTransportObject {

  TransportObject object;

  LatLng animatedLatLng;
  double animatedRotation;
  List<TransportAnimationKeyframe> pendingKeyframes = [];
  int keyframeStartMillis;
  TransportAnimationKeyframe previousKeyframe;
  TransportAnimationKeyframe currentKeyframe;

  AnimatedTransportObject(this.object, {this.pendingKeyframes});

}