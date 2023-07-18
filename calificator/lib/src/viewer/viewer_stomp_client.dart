import 'dart:async';
import 'dart:convert';

import 'package:calificator/src/settings/properties.dart';
import 'package:calificator/src/viewer/viewer_caravan_message.dart';
import 'package:calificator/src/viewer/viewer_caravan_score_message.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

class ViewerStompClient {

  static const String defaultLocation="DEFAULT";

  Function(ViewerCaravanMessage,ViewerStompClient)? refreshCalculatedScore;
  Function(ViewerCaravanScoreMessage)? refreshReceivedScore;

  StompClient? stompClient;

  String username;

  bool activated=false;

  StompUnsubscribe? notificationUnsubscription;
  StompUnsubscribe? scoreNotificationUnsubscription;

  ViewerStompClient(this.refreshCalculatedScore,this.refreshReceivedScore,this.username);

  void activate(BuildContext context) {

    if(!activated) {
      if(stompClient!=null){
        stompClient?.deactivate();
      }
      Properties.getWSServerUrl(context).then((url) {
        stompClient = StompClient(
          config: StompConfig(
              url: url,
              onConnect: onConnect,
              onWebSocketError: (dynamic error) {
                activated = false;
                print(error.toString());
              },
              onDisconnect: (StompFrame frame)
              {
                activated = false;
                removeSubscription();
              }
          ),
        );

        print("activating");
        stompClient?.activate();
        print("activated to"+url);
      });
    }
  }


  void removeSubscription() {
    print("Remove subscription");
    if(notificationUnsubscription!=null){
      notificationUnsubscription?.call();
    }
    if(scoreNotificationUnsubscription!=null){
      scoreNotificationUnsubscription?.call();
    }
  }

  void onConnect(StompFrame frame) {
    if(!activated && stompClient!=null) {
      print("subscribing");
      activated = true;
      if (refreshCalculatedScore != null) {
        notificationUnsubscription = stompClient?.subscribe(
          destination: '/topic/notifications/$defaultLocation/$username',
          callback: (frame) {
            var responseBody = json.decode(frame.body!);
            ViewerCaravanMessage message = ViewerCaravanMessage.fromJson(
                responseBody);
            if (responseBody != null) {
              refreshCalculatedScore!(message, this);
              print(message);
            }
          },
        );
      }

      if (refreshReceivedScore != null) {
        scoreNotificationUnsubscription = stompClient?.subscribe(
          destination: '/topic/notifications/score/$defaultLocation/$username',
          callback: (frame) {
            var responseBody = json.decode(frame.body!);
            ViewerCaravanScoreMessage message = ViewerCaravanScoreMessage
                .fromJson(
                responseBody);
            print("score message arrive " + message.position.toString());
            refreshReceivedScore!(message);
            print(message);
          },
        );
        print("subscribed");
      }
    }
  }

  void publish(double score,int position,String setCode){

    stompClient?.send(destination: "/app/score",body: '''{
    "location": "$defaultLocation",
    "position": $position,
    "score": $score,
    "predictor": "$username",
    "setCode": "$setCode"
    }''');
  }

  void deactivate(){
    if(stompClient!=null){
      print("deactivating");
      removeSubscription();
      stompClient?.deactivate();
      activated=false;
      stompClient=null;
    }
  }

}

