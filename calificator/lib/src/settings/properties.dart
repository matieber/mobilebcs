import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Properties{

  static String? serverPort;
  static String? serverHost;

  static Future<String> getHttpServerUrl(BuildContext context) {
    return DefaultAssetBundle.of(context).loadString('assets/my_config.json')
        .then((jsonString){
      dynamic jsonMap=jsonDecode(jsonString);
      serverHost ??= _getHost(jsonMap);
      serverPort ??= _getPort(jsonMap);

      return "http://"+serverHost!+":"+serverPort!;
    }
    );
  }

  static Future<String> getWSServerUrl(BuildContext context) {
    return DefaultAssetBundle.of(context).loadString('assets/my_config.json')
        .then((jsonString){
      dynamic jsonMap=jsonDecode(jsonString);
      serverHost ??= _getHost(jsonMap);
      serverPort ??= _getPort(jsonMap);

      return "ws://"+serverHost!+":"+serverPort!+"/nextjob";
    }
    );
  }

  static String _getPort(jsonMap) {
    String serverPort=jsonMap['serverPort'];
    if(serverPort==""){
      serverPort="8080";
    }
    return serverPort;
  }

  static String _getHost(jsonMap) {
    String serverHost=jsonMap['serverHost'];
    if(serverHost==""){
      if (Platform.isAndroid) {
        serverHost="10.0.2.2";
      } else if (Platform.isIOS) {
        serverHost="localhost";
      }
    }
    return serverHost;
  }

}