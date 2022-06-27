import 'dart:async';
import 'package:apinch/tabs/credit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apinch/services/creditService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:apinch/locator_service.dart' as di;

enum ConnectionStatus { navigating, idle }
enum MinCreditNotificationStatus { unawared_user, awared_user }

class ConnectionHandler {
  ConnectionStatus status;
  CreditUpdater creditUpdater;
  StreamSubscription creditUpdaterSuscription;
  int minCredNotificationThreshold = 5;
  MinCreditNotificationStatus minCredAlert = MinCreditNotificationStatus.unawared_user;

  ConnectionHandler() {
    _init();
  }



  _init() async {
    creditUpdater = di.sl<CreditUpdater>();
    status = ConnectionStatus.idle;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('creditNotifThres'))
      minCredNotificationThreshold = preferences.get('creditNotifThres');
    else
      preferences.setInt("creditNotifThres", minCredNotificationThreshold);
  }

  void startsNavigation() {
    if (status == ConnectionStatus.idle) {
      status = ConnectionStatus.navigating;

      creditUpdaterSuscription = creditUpdater.stream.listen((event) {
        if (status == ConnectionStatus.navigating) {
          int credit = event.boughtCredit + event.earnedCredit;
          if (credit > minCredNotificationThreshold) {
            //reseto flag que indica que el usuario está avisado de que se está
            //quedando sin crédito
            minCredAlert = MinCreditNotificationStatus.unawared_user;
          }
          else
            if (credit <= minCredNotificationThreshold &&
              minCredAlert == MinCreditNotificationStatus.unawared_user) {
                print(event.toString());
                _showNotificationWithDefaultSound();
                minCredAlert = MinCreditNotificationStatus.awared_user;
            }
        }
      });
      //start polling credit updates
      creditUpdater.pollCredit();
    }
  }

  void stopNavigation() {
    status = ConnectionStatus.idle;
    creditUpdaterSuscription?.cancel();
    minCredAlert = MinCreditNotificationStatus.unawared_user;
  }

  Future _showNotificationWithDefaultSound() async {
    FlutterLocalNotificationsPlugin flip =
        new FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings, onSelectNotification: selectNotification);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'aPinchId',
        'aPinch',
        'This channel is where Apinch application notifies the user of relevant'
            'application events.',
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: true,
        channelShowBadge: true,
        icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    // initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flip.show(
        0,
        'APinch',
        'Tu crédito Apinch se está acabando, ve a renovarlo pinchando aquí',
        platformChannelSpecifics,
        payload: 'Default_Sound');
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    MaterialPageRoute<void>(builder: (context) => CreditPage());
  }
}
