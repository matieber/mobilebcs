
import 'dart:io';
import 'dart:typed_data';

import 'package:calificator/src/diagram/diagram_response.dart';
import 'package:calificator/src/qualifier/qualifier_job_client.dart';
import 'package:calificator/src/viewer/viewer_caravan_message.dart';
import 'package:calificator/src/viewer/viewer_caravan_score_message.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calificator/src/ui_model/extension.dart';
import '../diagram/caravan_response.dart';
import '../diagram/diagram_client.dart';
import '../diagram/diagram_tab.dart';
import '../diagram/diagrams.dart';
import '../diagram/indicator.dart';
import '../diagram/line_chart.dart';
import '../menu/qualificator_side_menu.dart';
import '../image/image.dart';
import '../ui_model/dropdown.dart';
import 'viewer_stomp_client.dart';
import 'package:flutter/services.dart';

class ViewerPage extends StatefulWidget {

  static ViewerPage? page;
  bool first=false;

  User? _user;
  final DiagramClientHttp _diagramClientHttp;


  var serverUrl;

  final GlobalKey<DiagramViewerTabState> diagramKey = GlobalKey<DiagramViewerTabState>();

  ViewerPage( this.serverUrl, {Key? key})
      : _diagramClientHttp = DiagramClientHttp(),
        super(key: key);

  set user(User user) {
    _user=user;
    first=true;
  }

  @override
  State<ViewerPage> createState() => _ViewerPageState();

  static ViewerPage newPage(String serverUrl) {
    page ??= ViewerPage(serverUrl);
    return page!;

  }

}

class _ViewerPageState extends State<ViewerPage> {

  static const platform = const MethodChannel('io.flutter.calificator/calificator');


  String identification = "";
  String _score="";
  String setCode="";
  ImageProvider? imageProvider;



  ViewerStompClient? viewerStompClient;


  CaravanInfoResponse? caravanInfoResponse;


  Future<String> _getScore(Uint8List body,int position,String setCode,ViewerStompClient viewerStompClient) async {
    String score;
    try {
      final double result = await platform.invokeMethod('calculateScore',body);
      score = 'El puntaje es calculado $result.';
      viewerStompClient.publish(result, position,setCode);

    } on PlatformException catch (e) {
      score = "Error al calcular el puntaje: '${e.message}'.";
    }
    return score;



  }
  refreshCalculatedScore(ViewerCaravanMessage message, ViewerStompClient viewerStompClient) {
    setState(() {
      if(message.predictor==widget._user?.username) {
        _score = "Calculando puntaje";
      }else{
        _score = "Esperando Puntaje";
      }

    if(message.byteImages.isNotEmpty && message.predictor==widget._user?.username) {
      _getScore(message.byteImages.first,message.position,message.setCode,viewerStompClient).then((value)
          {
            setState(() {
              _score = value;
            });
          }
      );
    }
    
      setCode = message.setCode;
      identification = message.identification;
      setCaravans(3);
      if(message.byteImages.isNotEmpty) {
            imageProvider=MemoryImage(message.byteImages.first);
      }
      widget.diagramKey.currentState?.setDiagram();
    });


  }

  refreshReceivedScore(ViewerCaravanScoreMessage message){
    setState(() {
      if(message.setCode==setCode){
        _score="El puntaje recibido es "+message.score.toString();

      }
    });
    setCaravans(3);
  }

  void setCaravans(int retry) {
    if(retry>0) {
      widget._diagramClientHttp.getCaravanChart(this.context,identification).then((value) =>
          setState(() {
            caravanInfoResponse = value;
            if (caravanInfoResponse == null) {
              sleep(const Duration(milliseconds: 300));
              setCaravans(retry - 1);
            }
          })
      );
    }
  }





  @override
  Widget build(BuildContext context) {



    String username= "";
    if(widget.first&&widget._user!=null){
      widget.first=false;
      User? user = widget._user;
      String? name = user?.username;
      username=name!;
      viewerStompClient= ViewerStompClient(refreshCalculatedScore,refreshReceivedScore, username);
      viewerStompClient?.activate(context);
    }
    return
      DefaultTabController(
        length:2,
        child: Scaffold(
          drawer: QualificationSideMenu(widget.serverUrl,closeFunction:
              (){
              viewerStompClient?.deactivate();
              viewerStompClient=null;
              widget._user=null;
              widget.first=true;
            }),
          appBar: buildAppBar("Observador"),
          body: TabBarView(children:[
            buildViewerBody(),
            DiagramViewerTab(widget.diagramKey)
          ])
      )
      );
  }



  Column buildViewerBody() {
    return Column(
        children: [
          Text(identification),
          Container(
            height: 280,
            width: 280,
            child: FittedBox(
              child: MyImage(imageProvider),
              fit: BoxFit.fill,
            )
          ),
          Text(_score),
          CaravanLineChart(caravanInfoResponse),
        ],
      );
  }






  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (viewerStompClient != null) {
      viewerStompClient?.deactivate();
    }

    super.dispose();
  }


  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,
      bottom: const TabBar(
        tabs: [
          Tab(icon: ImageIcon(AssetImage("assets/images/cow-silhouette.png"))),
          Tab(icon: ImageIcon(AssetImage("assets/images/pie-chart.png"))),
        ],
      ),
    );
  }


}
