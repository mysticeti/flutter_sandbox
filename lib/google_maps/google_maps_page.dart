import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsPage extends StatefulWidget {
  static const id = "google_maps_page";
  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kQueenElizabethOlympicPark = CameraPosition(
    target: LatLng(51.54265, -0.00956),
    zoom: 14.4746,
  );

  static final CameraPosition _kPool = CameraPosition(
      bearing: 110, target: LatLng(51.53956, -0.03278), tilt: 20, zoom: 19.5);

  Future<void> _goToThePool() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kPool));
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    if (kIsWeb) {
      bodyWidget = Container(
        child: Center(
          child:
              Text('Google Maps plugin is not supported yet on this platform.'),
        ),
      );
    } else {
      bodyWidget = Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kQueenElizabethOlympicPark,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToThePool,
          label: Text('To the Pool'),
          icon: Icon(Icons.pool),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
    }
    return bodyWidget;
  }
}
