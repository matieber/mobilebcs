
import 'package:calificator/src/viewer/viewer_caravan_message.dart';
import 'package:calificator/src/viewer/viewer_caravan_score_message.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/viewer/viewer_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../diagram/caravan_response.dart';
import '../diagram/diagram_client.dart';
import '../diagram/diagram_tab.dart';
import '../menu/qualificator_side_menu.dart';
import 'viewer_stomp_client.dart';
import 'package:flutter/services.dart';

class ViewerPageMain extends StatefulWidget {

  static ViewerPageMain? page;
  bool first=false;

  User? _user;
  final DiagramClientHttp _diagramClientHttp;


  var serverUrl;

  final GlobalKey<DiagramViewerTabState> diagramKey = GlobalKey<DiagramViewerTabState>();



  ViewerPageMain( this.serverUrl)
      : _diagramClientHttp = DiagramClientHttp(),
        super(key: GlobalKey<ViewerPageMainState>());

  set user(User user) {
    if(_user==null && _user!=user) {
      _user = user;
      first = true;
    }
  }

  @override
  State<ViewerPageMain> createState() => ViewerPageMainState();

  static ViewerPageMain newPage(String serverUrl) {
    page ??= ViewerPageMain(serverUrl);
    return page!;

  }

}

class ViewerPageMainState extends State<ViewerPageMain> {

  String identification = "";
  String score="";
  String setCode="";
  ImageProvider? imageProvider;
  CaravanInfoResponse? caravans;
  List<String> qualifications=<String>[];

  String text="";

  ViewerStompClient? viewerStompClient;

  @override
  Widget build(BuildContext context) {

    String username= "";
    if(widget.first&&widget._user!=null){
      widget.first=false;
      User? user = widget._user;
      String? name = user?.username;
      username=name??"";
      viewerStompClient= ViewerStompClient(username);
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
              body: TabBarView(
                  children:[
                    ViewerPage(widget.key as GlobalKey<ViewerPageMainState>, viewerStompClient!,widget._diagramClientHttp,widget._user,widget.diagramKey),
                    DiagramViewerTab(widget.diagramKey)
                  ])
          )
      );
  }








  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (viewerStompClient != null) {
      viewerStompClient?.deactivate();
    }

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
