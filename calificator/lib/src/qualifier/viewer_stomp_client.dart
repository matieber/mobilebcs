import 'dart:async';
import 'dart:convert';

import 'package:calificator/src/qualifier/viewer_caravan_message.dart';
import 'package:calificator/src/qualifier/viewer_caravan_score_message.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ViewerStompClient {

  static const String defaultLocation="DEFAULT";

  Function(ViewerCaravanMessage,ViewerStompClient) notifyParent;
  Function(ViewerCaravanScoreMessage) notifyScore;

  StompClient? stompClient;

  String username;

  bool activated=false;

  ViewerStompClient(this.notifyParent,this.notifyScore,this.username);

  void activate() {

    if(!activated) {
      stompClient = StompClient(
        config: StompConfig(
            url: 'ws://10.0.2.2:8080/nextjob',
            onConnect: onConnect,
            beforeConnect: () async {
              print('waiting to connect...');
              await Future.delayed(Duration(milliseconds: 200));
              print('connecting...');
            },
            onWebSocketError: (dynamic error) {
              activated = false;
              print(error.toString());
            },
            onDisconnect: (StompFrame frame) => activated = false
        ),
      );

      stompClient?.activate();
    }
  }

  void onConnect(StompFrame frame) {
    if(!activated) {
      activated = true;
      stompClient?.subscribe(
        destination: '/topic/notifications/$defaultLocation/$username',
        callback: (frame) {
          var responseBody = json.decode(frame.body!);
          ViewerCaravanMessage message = ViewerCaravanMessage.fromJson(
              responseBody);
          notifyParent(message, this);
          print(message);
        },
      );
      stompClient?.subscribe(
        destination: '/topic/notifications/score/$defaultLocation/$username',
        callback: (frame) {
          var responseBody = json.decode(frame.body!);
          ViewerCaravanScoreMessage message = ViewerCaravanScoreMessage.fromJson(
              responseBody);
          print("score message arrive "+message.position.toString());
          notifyScore(message);
          print(message);
        },
      );
    }
  }

  void publish(double score,int position){

    stompClient?.send(destination: "/app/score",body: '''{
    "location": "$defaultLocation",
    "position": $position,
    "score": $score,
    "predictor": "$username"
    }''');
  }

}

