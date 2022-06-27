import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:apinch/constants.dart';
import 'package:logger/logger.dart';
import 'package:apinch/locator_service.dart' as di;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';

class AdvertsPage extends StatefulWidget {
  final VoidCallback goToCreditPage;
  AdvertsPage({Key key, this.goToCreditPage}) : super(key: key) {
    aPinchConService = di.sl<APinchConnectivityService>();
  }
  APinchConnectivityService aPinchConService;

  @override
  _AdvertsPageState createState() => _AdvertsPageState();
}

class _AdvertsPageState extends State<AdvertsPage> with LifecycleMixin {
  @override
  //bool isViewingAd = false;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  Timer timer;
  String _timeToWatch = AdsConstants.timeToWatchAds.toString();

//  Stopwatch _stopWatch = new Stopwatch();

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => setTime());
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void setTime() {
    APinchConnectivityService apser = widget.aPinchConService;
    final int watchedTime = apser.getElapsefTimeWatchAd().inSeconds;
    setState(() {
      _timeToWatch = "Segundos restantes para acreditar navegación: " +
          (AdsConstants.timeToWatchAds - watchedTime).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logger = di.sl<Logger>();

    logger.d("Building ad");
    APinchConnectivityService apser = widget.aPinchConService;

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: //SafeArea(
            //child:
            Column(
                //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              //          CircularProgressIndicator(),
              Text(_timeToWatch),
              //Builder(builder: (BuildContext context) {
              //return
              Expanded(
                  child: WebView(
                initialUrl: 'http://3.129.56.198/demo/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onPageStarted: (String url) {
                  apser.resetStartWatchAd();
                  logger.d('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  logger.d('Page finished loading: $url');
                  Future.delayed(Duration(seconds: AdsConstants.timeToWatchAds))
                      .whenComplete(_computeCreditAds);
                  //sleep(Duration(seconds: AdsConstants.timeToWatchAds)); //esto bloqueba todo...
                },
                gestureNavigationEnabled: true,
              )) //;
              //}),
            ]));
  }

  @override
  void onPause() {
    APinchConnectivityService apser = widget.aPinchConService;
    final logger = di.sl<Logger>();
    final int watchedTime = apser.getElapsefTimeWatchAd().inSeconds;
    logger.d('did pause timer: $watchedTime ');
    apser.stopWatchAd();
  }

  void _computeCreditAds() {

    final logger = di.sl<Logger>();
    final apser = widget.aPinchConService;

    final timeElap = apser.getElapsefTimeWatchAd();
    logger.d('acredito tiempo time add: $timeElap');
    final timeok = apser.stopResetWatchAd();
    logger.d('acredito tiempo time add: $timeok');

    doEarnedCreditPost();
    widget.goToCreditPage();
  }

  doEarnedCreditPost() async {
    final logger = di.sl<Logger>();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final addCreditjson = {
      'email': preferences.get('email'),
      'method': "ads",
      'amount': "10",
    };

    logger.d('Agregando créditos por publicidad: $addCreditjson');

    var response = await http
        .post(AppURLConstants.domain + AppURLConstants.creditURL, body: addCreditjson)
        .timeout(Duration(seconds: 10));
    final data = jsonDecode(response.body);
    var value = data['value'];
    var message = data['message'];
    logger.d('Credit POST response: value=$value message=$message');


  }

  @override
  void onResume() {
    final logger = di.sl<Logger>();

    APinchConnectivityService apser = widget.aPinchConService;
    apser.startWatchAd();
    final int watchedTime = apser.getElapsefTimeWatchAd().inSeconds;
    logger.d('did resume timer: $watchedTime ');
    Future.delayed(Duration(seconds: AdsConstants.timeToWatchAds - watchedTime))
        .whenComplete(_computeCreditAds);
  }

  /// optionally
  @override
  void afterFirstRender() {
    final logger = di.sl<Logger>();
    logger.d('run after first render');
  }

  @override
  void onDetached() {
    final logger = di.sl<Logger>();
    logger.d('detached');
    APinchConnectivityService apser = widget.aPinchConService;
    apser.stopWatchAd();
  }

  Future<void> _displayAd() async {
    final logger = di.sl<Logger>();
    var now = new DateTime.now();
    logger.d("Ad Start $now");
    setState(() {
      //    isViewingAd = true;
    });
    await Future.delayed(Duration(seconds: 10));

    //await _launchURL('http://3.129.56.198/demo/');
    var after = new DateTime.now();
    logger.d("Ad Stop $after");
    setState(() {
      //  isViewingAd = false;
    });
  }
}
