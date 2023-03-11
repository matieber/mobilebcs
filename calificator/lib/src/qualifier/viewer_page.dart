import 'dart:convert';
import 'dart:typed_data';

import 'package:calificator/src/qualifier/qualifier_job_client.dart';
import 'package:calificator/src/qualifier/viewer_caravan_message.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calificator/src/ui_model/extension.dart';
import 'package:stomp_dart_client/stomp.dart';
import '../menu/qualificator_side_menu.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'image.dart';
import 'viewer_stomp_client.dart';

class ViewerPage extends StatefulWidget {
  final User user;


  final QualifierJobClientHttp _client;

  var serverUrl;

  ViewerPage(this.user, this.serverUrl, {Key? key})
      : _client = QualifierJobClientHttp(serverUrl),
        super(key: key);

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  String position = "";

  ImageProvider? imageProvider;

  refresh(ViewerCaravanMessage message) {
    setState(() {
      position = message.position.toString();
      if(message.byteImages.isNotEmpty) {
            imageProvider=MemoryImage(message.byteImages.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewerStompClient viewerStompClient=ViewerStompClient(refresh);
    viewerStompClient.activate();
    return Scaffold(
        drawer: QualificationSideMenu(widget.serverUrl),
        appBar: buildAppBar(widget.user.userType.value.capitalize() +
            " - " +
            widget.user.username),
        body: buildBody()
    );
  }

  Column buildBody() {
    return Column(
        children: [
          Text(position),
           MyImage(imageProvider),
        ],
      );
  }

  @override
  void initState() {
    super.initState();
  }

/*  @override
  void dispose() {
    final stompClient = this.stompClient;
    if (stompClient != null) {
      stompClient.deactivate();
    }

    super.dispose();
  }
  */

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,
    );
  }

/*
    Timer.periodic(duration, (Timer timer) {
      widget._client.nextJob(widget.user.username.toString()).then((response) =>
      {
        if(response != null && response.isNotEmpty){
          setState(() {
            if (response.containsKey("position")) {
              widget._position = response.remove("position");
            }
          })
        }
      });
      /*setState(() {
        widget._position++;
        print(widget.user.username.toString()+" "+widget._position.toString());
      });*/

    });
    */

}
