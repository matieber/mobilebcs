import 'dart:async';
import 'dart:convert';

import 'package:calificator/src/qualifier/viewer_caravan_message.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ViewerStompClient {

  static const String defaultLocation="DEFAULT";

  Function(ViewerCaravanMessage) notifyParent;

  StompClient? stompClient;

  ViewerStompClient(this.notifyParent);

  void activate() {

    stompClient=StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/nextjob',
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );

    stompClient?.activate();
  }

  void onConnect(StompFrame frame) {
    stompClient?.subscribe(
      destination: '/topic/notifications/$defaultLocation',
      callback: (frame) {
        var responseBody = json.decode(frame.body!);
        ViewerCaravanMessage message = ViewerCaravanMessage.fromJson(
            responseBody);
        notifyParent(message);
        print(message);
      },
    );
  }

}

