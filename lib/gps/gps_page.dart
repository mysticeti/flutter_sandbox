import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sandbox/pageNavigatorCustom.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GPSPage extends StatefulWidget {
  static const id = 'gps_page';
  @override
  _GPSPageState createState() => _GPSPageState();
}

class _GPSPageState extends State<GPSPage> {
  LocationAccuracy _selectedLocationAccuracy = LocationAccuracy.high;
  bool serviceEnabled;
  LocationPermission permission;

  Future<Position> _determinePosition() async {
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error(
          AppLocalizations.of(context).gpsLocationsServiceDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(AppLocalizations.of(context)
            .gpsLocationsServicePermanentlyDisabled);
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(
            AppLocalizations.of(context).gpsLocationsServiceDenied);
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: _selectedLocationAccuracy);
  }

  Position _currentPos;
  TextStyle gpsTextStyle = TextStyle(fontSize: 30);

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
    analytics.logEvent(name: 'gps_page');
    final PageNavigatorCustom _pageNavigator =
        Provider.of<PageNavigatorCustom>(context);
    _pageNavigator.setCurrentPageIndex = _pageNavigator.getPageIndex("GPS");
    _pageNavigator.setFromIndex = _pageNavigator.getCurrentPageIndex;
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownButton<LocationAccuracy>(
          value: _selectedLocationAccuracy,
          style: TextStyle(color: Theme.of(context).accentColor),
          underline: Container(
            height: 2,
            color: Theme.of(context).accentColor,
          ),
          onChanged: (LocationAccuracy newValue) {
            setState(() {
              _selectedLocationAccuracy = newValue;
            });
          },
          items: <LocationAccuracy>[
            LocationAccuracy.lowest,
            LocationAccuracy.low,
            LocationAccuracy.medium,
            LocationAccuracy.high,
            LocationAccuracy.best,
            LocationAccuracy.bestForNavigation,
          ].map<DropdownMenuItem<LocationAccuracy>>((LocationAccuracy value) {
            return DropdownMenuItem<LocationAccuracy>(
              value: value,
              child: Text(
                value.toString(),
                style: GoogleFonts.lato(),
              ),
            );
          }).toList(),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${localizations.gpsLatitude} : ',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                fontSize: 20,
              )),
            ),
            (_currentPos != null)
                ? Text(
                    _currentPos.latitude.toString(),
                    style: GoogleFonts.lato(textStyle: gpsTextStyle),
                  )
                : Text(
                    '0.0',
                    style: GoogleFonts.lato(textStyle: gpsTextStyle),
                  ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${localizations.gpsLongitude} : ',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                fontSize: 20,
              )),
            ),
            (_currentPos != null)
                ? Text(
                    _currentPos.longitude.toString(),
                    style: GoogleFonts.lato(textStyle: gpsTextStyle),
                  )
                : Text(
                    '0.0',
                    style: GoogleFonts.lato(textStyle: gpsTextStyle),
                  ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            Position positionValue = await _determinePosition();
            setState(() {
              _currentPos = positionValue;
            });
          },
          child: Text(
            localizations.gpsLocateMe,
            style: GoogleFonts.lato(),
          ),
        ),
      ],
    );
  }
}
