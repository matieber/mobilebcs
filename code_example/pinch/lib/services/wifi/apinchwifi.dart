import 'package:apinch/services/connectionHandler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:device_info/device_info.dart';
import 'package:system_setting/system_setting.dart';
import 'package:apinch/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:apinch/locator_service.dart' as di;
import 'package:easyping/easyping.dart';
import 'package:tcp_scanner/tcp_scanner.dart';
import 'package:get_mac/get_mac.dart';
import 'dart:convert';
import 'package:apinch/services/ssl/ssl.dart';

class APinchConnectivityService {
// Create our public controller
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();

  ConnectionHandler connHandler;

  bool _isActivated = false;
  bool _isAndroid29 = false;
  ConnectivityStatus _status = null;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Stopwatch _stopWatch = new Stopwatch();

  APinchConnectivityService(this.connHandler) {
    // Subscribe to the connectivity Chanaged Steam
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      final logger = di.sl<Logger>();
      var status = _getStatusFromResult(result);
      _status = status;

      if (status == ConnectivityStatus.WiFi) {
        var aWifi = await getWifi() == WifiConstants.openWifi;
        var aODNS = await isConnectedToOpennds();
        logger.d("aWifi: $aWifi");
        logger.d("aODNS: $aODNS");
        if (aWifi || aODNS) _status = ConnectivityStatus.APinch;
        if (!await isConnected()) connHandler.stopNavigation();
      } else
        connHandler.stopNavigation();

      logger.d("APinchWifi Connectivity status dispatched: $_status");

      connectionStatusController.add(_status);
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  bool stopResetWatchAd() {
    _stopWatch.stop();
    final isValid = _stopWatch.elapsed.inSeconds >= AdsConstants.timeToWatchAds;
    _stopWatch.reset();
    return isValid;
  }

  void resetStartWatchAd() {
    _stopWatch.reset();
    _stopWatch.start();
  }

  void startWatchAd() {
    _stopWatch.start();
  }

  Duration getElapsefTimeWatchAd() {
    return _stopWatch.elapsed;
  }

  void stopWatchAd() {
    _stopWatch.stop();
  }

  bool get isActivated => this._isActivated;

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.WiFi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }

  Future<Null> switchOnOff({enable = true}) async {
    if (enable) {
      await connect();
    } else {
      await disconnect();
    }
  }

  Future<Null> connect() async {
    final logger = di.sl<Logger>();
    logger.d("connect");
    final bool isCon = await isConnected();
    if (!isCon) {
      final conec = await _connectionOpen(WifiConstants.openWifi);
      print(conec);
    } else
      //ver si es necesario
      _status = ConnectivityStatus.APinch;
    connectionStatusController.add(_status);
  }

  Future<Null> disconnect() async {
    print("disconnect");
    _isActivated = false;
    connHandler.stopNavigation();
    await WiFiForIoTPlugin.disconnect();
  }

  Future<String> getWifi() async {
    return await WiFiForIoTPlugin.getSSID();
  }

  Future<bool> isConnectedToOpennds() async {
    try {
      var result = await TCPScanner("192.168.101.21", [2050]).scan();
      return result.open.contains(2050);
    } on Exception catch (_) {
      print('not connected');
      return false;
    }
  }

  Future<bool> isConnectedToOpennds_ping() async {
    try {
      double pingToAddress = await ping('192.168.101.21');
      if (pingToAddress > 9) {
        print('connected');
        return true;
      } else
        return false;
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

  Future<String> getIp() async {
    if (_status == ConnectivityStatus.WiFi)
      return await WiFiForIoTPlugin.getIP();
    else
      return "";
  }

  Future<List<WifiNetwork>> list(String key) async {
    List<WifiNetwork> allList;
    try {
      allList = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      allList = List<WifiNetwork>();
    }

    final logger = di.sl<Logger>();
    logger.d("Lista de redes: $allList");
    List<WifiNetwork> resultList = [];
    for (int i = 0; i < allList.length; i++) {
      if (allList[i].ssid == key) resultList.add(allList[i]);
    }
    return resultList;
  }

  Future<bool> isConnected() async {
    final aWifi = await getWifi();
    final aODNS = isConnectedToOpennds();
    if (aWifi != WifiConstants.openWifi) {
      return aODNS;
    }
    return true;
  }

  Future<bool> isAndroid29() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 29) return true;
    }

    return false;
  }

  Future<WIFI_AP_STATE> _connectionOpen(String wifiName) async {
    final logger = di.sl<Logger>();
    logger.d("connect");
    if (Platform.isAndroid) {
      print("android 29");
      //https://stackoverflow.com/questions/55592392/how-to-fix-neterr-cleartext-not-permitted-in-flutter
      //problem de error al abrir navegador
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 29) {
        //Android sdk >= 29 use system wifi
        await SystemSetting.goto(SettingTarget.WIFI);
        return WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
      }
    }
    //android <29 and iphone
    final isConnected = await WiFiForIoTPlugin.connect(
      wifiName,
      security: NetworkSecurity.NONE,
      //   password: '',
      joinOnce: false,
    );

    if (isConnected) {
      logger.d("Connected");
      return WIFI_AP_STATE.WIFI_AP_STATE_ENABLED;
    } else {
      logger.d("Failed to connect");
      return WIFI_AP_STATE.WIFI_AP_STATE_FAILED;
    }
  }

  Future<String> getSessionId() async {
    //final response = await http.get(Uri.parse('http://192.168.101.21:2050/'));

    final logger = di.sl<Logger>();
    logger.d("autentificate");

    var macAddr = '';
    var sessionId = '';

    try {
      macAddr = await GetMac.macAddress;
    } on PlatformException {
      macAddr = 'Failed to get Device MAC Address.';
    }

    logger.d("MAc addr: $macAddr");
    //http: //168.90.72.46:15221/v1/status/24:41:8c:03:51:d8
    //var endpointUrl = 'http://168.90.72.46:15221/v1/status/38:f7:3d:ab:0b:8e';
    var endpointUrl = 'http://168.90.72.46:15221/v1/status/$macAddr';

    //con local anda
    //var endpointUrl = AppURLConstants.domain + '/status';
    //var response = await http.get(endpointUrl);

    logger.d("http call: $endpointUrl");

    try {
      //final response = await http.get(Uri.parse(endpointUrl));
      await Future.delayed(Duration(seconds: 3));
      var response = await http.get(endpointUrl).timeout(Duration(seconds: 5));

      logger.d("response: $response");
      if (response.statusCode != 200) {
        logger.d("Failed to get session id");
        throw Exception('Failed to get SessioId');
      } else {
        final sslserv = di.sl<APinchSSLService>();
        final responsedec = sslserv.decrypt(response.body);
        final responseJson = json.decode(responsedec);
        sessionId = responseJson['session_id'];
        logger.d("Session id: $sessionId");
      }
    } catch (e) {
      logger.d("Failed to get session id $e");
    }
    return sessionId;
  }

/*
  Future<void> autentificate() async {
    final id = await getSessionId();
    final logger = di.sl<Logger>();

    if (id != null) {
      var endpointUrl = 'http://168.90.72.46:14221/fas/$id/auth';

      try {
        _launchURL(endpointUrl);
        _isActivated = true;
        connHandler.startsNavigation();

        logger.d("Autnetifico ");
      } catch (e) {
        logger.d("Problema autentificacion");
        logger.d(e);
      }
    }
  }
*/
/*  _launchURL(url, {time_sec = 2}) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: true,
          forceWebView: true,
          headers: <String, String>{'my_header_key': 'my_header_value'});
      Timer(Duration(seconds: time_sec), () {
        print('Closing WebView after 2 seconds...');
        closeWebView();
      });
    } else {
      throw 'Could not launch $url';
    }
  }*/
}
