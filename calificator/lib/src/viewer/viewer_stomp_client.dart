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

  Function(ViewerCaravanMessage,ViewerStompClient)? refreshCaravan;
  Function(ViewerCaravanScoreMessage)? refreshReceivedScore;

  static StompClient? stompClient;

  String username;

  static bool activated=false;

  StompUnsubscribe? notificationUnsubscription;
  StompUnsubscribe? scoreNotificationUnsubscription;

  ViewerStompClient(this.username);

  void activate(BuildContext context) {
    if(activated){
      if(stompClient!=null){
       deactivate();
      }
    }else {
      internalActivation(context);
    }

  }



  void internalActivation(BuildContext context) {
    Properties.getWSServerUrl(context).then((url) {
      stompClient = StompClient(
        config: StompConfig(
          url: url,
          onConnect: onConnect,
          onWebSocketError: (dynamic error) {
            print(error.toString());
            deactivate();
          },
        ),
      );

      stompClient?.activate();
    });
  }


  void removeSubscription() {
    if(notificationUnsubscription!=null){
      notificationUnsubscription!(unsubscribeHeaders: {});
    }
    if(scoreNotificationUnsubscription!=null){
      scoreNotificationUnsubscription!(unsubscribeHeaders: {});
    }
  }

  void onConnect(StompFrame frame) {
    if(!activated && stompClient!=null) {
      activated = true;
      caravanSubscription();
      refreshScoreSubscription();
    }
  }

  void refreshScoreSubscription() {
    if (refreshReceivedScore != null) {
      scoreNotificationUnsubscription = stompClient?.subscribe(
        destination: '/topic/notifications/score/$defaultLocation/$username',
        callback: (frame) {
          var responseBody = json.decode(frame.body!);
          ViewerCaravanScoreMessage message = ViewerCaravanScoreMessage
              .fromJson(
              responseBody);
          refreshReceivedScore!(message);
        },
      );
    }
  }

  void caravanSubscription() {
     if (refreshCaravan != null) {
      notificationUnsubscription = stompClient?.subscribe(
        destination: '/topic/notifications/$defaultLocation/$username',
        callback: (frame) {

          var responseBody = json.decode(frame.body!);
          ViewerCaravanMessage message = ViewerCaravanMessage.fromJson(
              responseBody);
          if (responseBody != null) {
            DateTime startTime=message.startTimeUTC;
            int index=message.position;
            var endTineUTC = DateTime.now().toUtc();
            print("network-time: index $index in "+endTineUTC.difference(startTime).inMilliseconds.toString());
            refreshCaravan!(message, this);
          }
        },
      );
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
      removeSubscription();
      stompClient?.deactivate();
      activated=false;
      stompClient=null;
    }
  }

}

