import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sandbox/pageNavigatorCustom.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FlutterMapPage extends StatefulWidget {
  const FlutterMapPage({Key key}) : super(key: key);
  static const id = 'flutter_map_page';

  @override
  _FlutterMapPageState createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
    analytics.logEvent(name: 'flutter_map_page');
    final PageNavigatorCustom _pageNavigator =
        Provider.of<PageNavigatorCustom>(context);
    _pageNavigator.setCurrentPageIndex =
        _pageNavigator.getPageIndex("Flutter Map");
    _pageNavigator.setFromIndex = _pageNavigator.getCurrentPageIndex;

    MapOptions customOptions = MapOptions(
      center: LatLng(51.5, -0.09), // London
      zoom: 13.0,
    );

    return Container(
      child: FlutterMap(
        mapController: mapController,
        options: customOptions,
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
        ],
      ),
    );
  }
}
