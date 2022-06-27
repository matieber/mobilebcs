import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:apinch/constants.dart';
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:apinch/locator_service.dart' as di;

import 'main.dart';

//todo dejar boton para 29 y casi nada para el resto...poner logo y que se esta conectando

class WaitNetworksPage extends StatefulWidget {
  final VoidCallback notSignIn;
  APinchConnectivityService aPinchConService;
  @override
  _WaitNetworksPageState createState() => new _WaitNetworksPageState();

  WaitNetworksPage(this.aPinchConService, this.notSignIn);
}

class _WaitNetworksPageState extends State<WaitNetworksPage> {
  List<WifiNetwork> ssidList = [];
  int level = 0;
  String ssid = '', password = '';
  bool _isAndroid29 = true;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    var titleText = "Para disfrutar de la red apinch, presiona el botón debajo";
    if (_isAndroid29) {
      titleText = titleText +
          ". Irás al menú de redes del sistema. Conecta a openwireless.org y luego regresa a la app!";
    }
    final logger = di.sl<Logger>();

    logger.d("Connectivity Status: $connectionStatus");

    return WillPopScope(
        onWillPop: () => MyApp.onBackPressed(context),
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(AppURLConstants.mainImageURL),
                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          height: 120,
                          child: Text(
                            titleText,
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),

                        SizedBox(
                          height: 12,
                        ),
/*
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(connectionStatus.toString()),
                        ]),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          FutureBuilder(
                              future: widget.aPinchConService.getWifi(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> text) {
                                if (text.hasError)
                                  return Text('Error: ${text.error}');
                                switch (text.connectionState) {
                                  case ConnectionState.done:
                                    return new Text(text.data ?? "Error");
                                    break;
                                  default:
                                    return CircularProgressIndicator();
                                }
                              }),
                        ]),
                    SizedBox(
                      height: 25,
                    ),*/

                        buildWifiButton(connectionStatus),

                        Padding(
                          padding: EdgeInsets.all(14.0),
                        ),

                        //buildWifiList(connectionStatus),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildWifiButton(connectionStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        !isConnecting
            ? RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Text(
                  'Ingresar a WiFi apinch',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                color: Theme.of(context).accentColor,
                onPressed: _connectWifi,
              )
            : Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget buildWifiList(connectionStatus) {
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: ssidList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        return itemSSID(index, connectionStatus);
      },
    );
  }

  Widget itemSSID(index, connectionStatus) {
    if (index == 0) {
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
            /*ssid = ssidList[index - 1].ssid;

            //password = WifiConstants.privateWifiPassword;
            password = WifiConstants.openWifiPassword;
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Tile ${ssidList[index - 1].ssid} clicked"),
            ));
            connection();*/
          },
        ),
        Divider(),
      ]);
    }
  }

  void loadData() async {
    var android = await widget.aPinchConService.isAndroid29();
    //var list = await Wifi.list(WifiConstants.openWifi);
    var list = await widget.aPinchConService.list(WifiConstants.openWifi);
    setState(() {
      ssidList = list;
      _isAndroid29 = android;
    });
  }

  Future<String> _connectWifi() async {
    print("Connect wifi wait network");
    setState(() {
      isConnecting = true;
    });
    await widget.aPinchConService.switchOnOff(enable: true);
    await Future.delayed(Duration(seconds: 5));

    widget.notSignIn();
    setState(() {
      isConnecting = false;
    });
    return "Connected";
  }

  /*Future<Null> _getWifiName() async {
    int l = await Wifi.level;
    String wifiName = await Wifi.ssid;
    setState(() {
      level = l;
      _wifiName = wifiName;
    });
  }*/

  /*Future<Null> _getIP() async {
    String ip = await Wifi.ip;
    setState(() {
      _ip = ip;
    });
  }*/
}
