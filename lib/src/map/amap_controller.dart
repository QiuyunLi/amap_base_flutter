import 'dart:async';
import 'dart:convert';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/map/model/marker_options.dart';
import 'package:amap_base/src/map/model/my_location_style.dart';
import 'package:amap_base/src/map/model/poi_result.dart';
import 'package:amap_base/src/map/model/poi_search_query.dart';
import 'package:amap_base/src/map/model/polyline_options.dart';
import 'package:amap_base/src/map/model/route_plan_param.dart';
import 'package:amap_base/src/map/model/route_poi_result.dart';
import 'package:amap_base/src/map/model/ui_settings.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class AMapController {
  final MethodChannel _mapChannel;
  final EventChannel _markerClickedEventChannel;

  AMapController.withId(int id)
      : _mapChannel = MethodChannel('me.yohom/map$id'),
        _markerClickedEventChannel = EventChannel('me.yohom/marker_clicked$id');

  void dispose() {}

  //region dart -> native
  Future setMyLocationStyle(MyLocationStyle style) {
    final _styleJson =
        jsonEncode(style?.toJson() ?? MyLocationStyle().toJson());

    L.p('方法setMyLocationStyle dart端参数: styleJson -> $_styleJson');
    return _mapChannel.invokeMethod(
      'map#setMyLocationStyle',
      {'myLocationStyle': _styleJson},
    );
  }

  Future setUiSettings(UiSettings uiSettings) {
    final _uiSettings = jsonEncode(uiSettings.toJson());

    L.p('方法setUiSettings dart端参数: _uiSettings -> $_uiSettings');
    return _mapChannel.invokeMethod(
      'map#setUiSettings',
      {'uiSettings': _uiSettings},
    );
  }

  Future calculateDriveRoute(
    RoutePlanParam param, {
    bool showRouteImmediately = true,
  }) {
    final _routePlanParam = param.toJsonString();
    L.p('方法calculateDriveRoute dart端参数: _routePlanParam -> $_routePlanParam');
    return _mapChannel.invokeMethod(
      'map#calculateDriveRoute',
      {
        'routePlanParam': _routePlanParam,
        'showRouteImmediately': showRouteImmediately,
      },
    );
  }

  Future addMarker(MarkerOptions options) {
    final _optionsJson = options.toJsonString();
    L.p('方法addMarker dart端参数: _optionsJson -> $_optionsJson');
    return _mapChannel.invokeMethod(
      'marker#addMarker',
      {'markerOptions': _optionsJson},
    );
  }

  Future addMarkers(List<MarkerOptions> optionsList,
      {bool moveToCenter = true, bool clear = true}) {
    final _optionsListJson =
        jsonEncode(optionsList.map((it) => it.toJson()).toList());
    L.p('方法addMarkers dart端参数: _optionsListJson -> $_optionsListJson');
    return _mapChannel.invokeMethod(
      'marker#addMarkers',
      {
        'moveToCenter': moveToCenter,
        'markerOptionsList': _optionsListJson,
        'clear': clear,
      },
    );
  }

  Future showIndoorMap(bool enable) {
    return _mapChannel.invokeMethod(
      'map#showIndoorMap',
      {'showIndoorMap': enable},
    );
  }

  Future setMapType(int mapType) {
    return _mapChannel.invokeMethod(
      'map#setMapType',
      {'mapType': mapType},
    );
  }

  Future setLanguage(int language) {
    return _mapChannel.invokeMethod(
      'map#setLanguage',
      {'language': language},
    );
  }

  Future clearMarkers() {
    return _mapChannel.invokeMethod('marker#clear');
  }

  Future clearMap() {
    return _mapChannel.invokeMethod('map#clear');
  }

  /// 设置缩放等级
  Future setZoomLevel(int level) {
    L.p('setZoomLevel dart端参数: level -> $level');

    return _mapChannel.invokeMethod(
      'map#setZoomLevel',
      {'zoomLevel': level},
    );
  }

  /// 设置地图中心点
  Future setPosition({
    @required LatLng target,
    double zoom = 10,
    double tilt = 0,
    double bearing = 0,
  }) {
    L.p('setPosition dart端参数: target -> $target, zoom -> $zoom, tilt -> $tilt, bearing -> $bearing');

    return _mapChannel.invokeMethod(
      'map#setPosition',
      {
        'target': target.toJsonString(),
        'zoom': zoom,
        'tilt': tilt,
        'bearing': bearing,
      },
    );
  }

  /// 限制地图的显示范围
  Future setMapStatusLimits({
    /// 西南角 [Android]
    @required LatLng swLatLng,

    /// 东北角 [Android]
    @required LatLng neLatLng,

    /// 中心 [iOS]
    @required LatLng center,

    /// 纬度delta [iOS]
    @required double deltaLat,

    /// 经度delta [iOS]
    @required double deltaLng,
  }) {
    L.p('setPosition dart端参数: swLatLng -> $swLatLng, neLatLng -> $neLatLng, center -> $center, deltaLat -> $deltaLat, deltaLng -> $deltaLng');

    return _mapChannel.invokeMethod(
      'map#setMapStatusLimits',
      {
        'swLatLng': swLatLng.toJsonString(),
        'neLatLng': neLatLng.toJsonString(),
        'center': center.toJsonString(),
        'deltaLat': deltaLat,
        'deltaLng': deltaLng,
      },
    );
  }

  /// 添加线
  Future addPolyline(PolylineOptions options) {
    L.p('addPolyline dart端参数: options -> $options');

    return _mapChannel.invokeMethod(
      'map#addPolyline',
      {'options': options.toJsonString()},
    );
  }

  //endregion

  /// marker点击事件流
  Stream<MarkerOptions> get markerClickedEvent => _markerClickedEventChannel
      .receiveBroadcastStream()
      .map((data) => MarkerOptions.fromJson(jsonDecode(data)));
}
