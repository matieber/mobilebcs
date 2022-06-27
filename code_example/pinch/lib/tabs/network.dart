import 'dart:async';
import 'package:flutter/material.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:wifi_iot/wifi_iot.dart';

import 'package:apinch/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:provider/provider.dart';

class NetworksPage extends StatefulWidget {
  APinchConnectivityService aPinchConService;
  @override
  _NetworksPageState createState() => new _NetworksPageState();

  NetworksPage(this.aPinchConService);
}

class _NetworksPageState extends State<NetworksPage> {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  String _ip = 'click button to get ip.';
  List<WifiNetwork> ssidList = [];
  String ssid = '', password = '';
  //bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /***@override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: ssidList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return itemSSID(index, connectionStatus);
          },
        ),
      ),
    );
  }**/

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(
            'Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    return FlutterMap(
      options: MapOptions(
        bounds: LatLngBounds(latLng.LatLng(-37.30, -59.10), latLng.LatLng(-37.33, -59.14)),
        boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(8.0)),
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.31, -59.13),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.amber),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.315, -59.135),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.green),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.32, -59.12),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.green),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.317, -59.125),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.red),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.319, -59.101),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.green),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.325, -59.125),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.amber),
                  ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(-37.307, -59.105),
              builder: (ctx) =>
                  Container(
                    child: Icon(Icons.wifi, color: Colors.red),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget itemSSID(index, connectionStatus) {
    if (index == 0) {
      return Column(
        children: [
          /*  Row(children: <Widget>[
            Switch(
              value: widget.aPinchConService.isActivated,
              onChanged: (value) {
                setState(() {
                  widget.aPinchConService.switchOnOff(enable: value);
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            Text(
              'Desactivar / Activar Navegacion',
              style: Theme.of(context).textTheme.bodyText2,s
            ),
          ]),
          Row(children: <Widget>[
            Switch(
              value: widget.aPinchConService.isEnabledAutoAuth,
              onChanged: (value) {
                setState(() {
                  widget.aPinchConService.isEnabledAutoAuth = value;
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            Text(
              'Autentificacion automatica cuando se conecta a la red apinch',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ]),*/
          Row(children: <Widget>[
            Text(connectionStatus.toString()),
          ]),
          Row(children: <Widget>[
            FutureBuilder(
                future: widget.aPinchConService.getWifi(),
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  if (text.hasError) return Text('Error: ${text.error}');
                  switch (text.connectionState) {
                    case ConnectionState.done:
                      return new Text(text.data);
                      break;
                    default:
                      return CircularProgressIndicator();
                  }
                }),
          ]),
          Row(children: <Widget>[
            FutureBuilder(
                future: widget.aPinchConService.getIp(),
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  if (text.hasError) return Text('Error: ${text.error}');
                  switch (text.connectionState) {
                    case ConnectionState.done:
                      return new Text(text.data);
                      break;
                    default:
                      return CircularProgressIndicator();
                  }
                }),
          ]),
          Row(children: <Widget>[Text("Redes Cercanas")]),
        ],
      );
    } else {
      return Column(children: <Widget>[
        ListTile(
          leading: Image.asset('images/wifi${ssidList[index - 1].level}.png',
              width: 28, height: 21),
          title: Text(
            ssidList[index - 1].ssid,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          dense: true,
          onTap: () {
            ssid = ssidList[index - 1].ssid;

            //password = WifiConstants.privateWifiPassword;
            password = WifiConstants.openWifiPassword;
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Tile ${ssidList[index - 1].ssid} clicked"),
            ));
            connection();
          },
        ),
        Divider(),
      ]);
    }
  }

  void loadData() async {
    widget.aPinchConService.list(WifiConstants.openWifi).then((list) {
      setState(() {
        ssidList = list;
      });
    });
  }

  Future<Null> connection() async {
    print("ssid for connect: $ssid");
    final conec = await widget.aPinchConService.connect();

    print(conec);
  }

  Future<Null> disconnect() async {
    print("disconnect");
    await widget.aPinchConService.disconnect();
  }
}
