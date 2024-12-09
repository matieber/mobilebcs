
import 'dart:io';
import 'dart:typed_data';
import 'package:calificator/src/diagram/diagram_tab.dart';
import 'package:calificator/src/viewer/viewer_caravan_message.dart';
import 'package:calificator/src/viewer/viewer_caravan_score_message.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/viewer/viewer_page_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../diagram/diagram_client.dart';
import '../diagram/line_chart.dart';
import '../image/image.dart';
import 'viewer_stomp_client.dart';
import 'package:flutter/services.dart';
import 'dart:developer';


class ViewerPage extends StatefulWidget {

  final String img_path = "/sdcard/Download/my.png";

  final DiagramClientHttp _diagramClientHttp;
  User? _user;

  GlobalKey<CaravanLineChartState> caravanDiagramKey= GlobalKey<CaravanLineChartState>();
  final GlobalKey<DiagramViewerTabState> diagramKey;

  var serverUrl;
  ViewerStompClient viewerStompClient;
  GlobalKey<ViewerPageMainState> mainKey;
  ViewerPage(this.mainKey,this.viewerStompClient,this._diagramClientHttp,this._user, this.diagramKey);


  @override
  State<ViewerPage> createState() => ViewerPageState();


}

class ViewerPageState extends State<ViewerPage> {

  static const platform = const MethodChannel('io.flutter.calificator/calificator');



  Future<int> getImg(
      int retryNmb,
      int requestStartMillis,
      String imgPath,
      List<int> content,
      ) async {
    if (retryNmb > 3) {
      throw Exception("Max retries reached while trying to save the image.");
    }

    try {
      final file = File(imgPath);
      await file.writeAsBytes(content);
    } catch (e) {
      // Registrar el error y reintentar
      print("Retrying image save, attempt #${retryNmb + 1}: $e");
      return await getImg(retryNmb + 1, requestStartMillis, imgPath, content);
    }

    // Devolver la diferencia de tiempo en milisegundos
    return DateTime.now().millisecondsSinceEpoch - requestStartMillis;
  }


  Future<String> _getScore(Uint8List body,int position,String setCode,ViewerStompClient viewerStompClient) async {
    final userTag = UserTag('GetScore');
    userTag.makeCurrent();
    String score;
    try {
      int index=position;

      DateTime processingStart=DateTime.now();
      final arguments = {
        "position": position,
      };
      int endGettingImage=await getImg(0, DateTime.now().millisecondsSinceEpoch,widget.img_path,body);
      DateTime beforePlugin=DateTime.now();
      final double result = await platform.invokeMethod('calculateScore',arguments);
      DateTime processingEnd=DateTime.now();
      score = 'El puntaje es calculado $result.';
      int processingTime=processingEnd.difference(processingStart).inMilliseconds;
      viewerStompClient.publish(result, position,setCode);
      widget.caravanDiagramKey.currentState?.addNewSetCode(setCode, result);
      print("before-plugin-processing-score: index $index in ${beforePlugin.toString()}\n"
          "saving-image-pre-processing-score: index $index in ${endGettingImage.toString()}\n"
          "calling-plugin-processing-score: index $index calculate scored was called\n"
          "index $index scored got was ${result.toString()}\n"
          "completed-processing-score: index $index in $processingTime ms");
    } on PlatformException catch (e) {
      score = "Error al calcular el puntaje: '${e.message}'.";
    }
    UserTag.defaultTag.makeCurrent();
    return score;

  }

  refreshCalculatedScore(ViewerCaravanMessage message, ViewerStompClient viewerStompClient) {
      if(message.predictor==widget._user?.username) {
        setScore("Calculando puntaje");
      }else{
        setScore("Esperando Puntaje");
      }

    if(message.byteImages.isNotEmpty && message.predictor==widget._user?.username) {
      _getScore(message.byteImages.first,message.position,message.setCode,viewerStompClient).then((value)
          {
              setScore(value);
          }
      );
    }

      setCode(message);
      setIdentification(message.identification);
      if(mounted) {
        setCaravans(3);
      }
      if(message.byteImages.isNotEmpty) {
        setImageProviderWith(message);
      }
     widget.diagramKey.currentState?.setPieDiagram();



  }

  void setImageProviderWith(ViewerCaravanMessage message) {
    if(mounted){
      setState(() {
        widget.mainKey.currentState!.imageProvider=MemoryImage(message.byteImages.first);
      });
    }else{
      widget.mainKey.currentState!.imageProvider=MemoryImage(message.byteImages.first);
    }
  }

  void setImageProvider(ImageProvider? imageProvider) {
    if(mounted){
      setState(() {
        widget.mainKey.currentState!.imageProvider=imageProvider;
      });
    }else{
      widget.mainKey.currentState!.imageProvider=imageProvider;
    }
  }

  void setIdentification(String identification) {
    if(mounted){
      setState(() {
        widget.mainKey.currentState!.identification = identification;
      });
    }else{
      widget.mainKey.currentState!.identification = identification;
    }

  }

  void setCode(ViewerCaravanMessage message) {
    if(mounted){
      setState(() {
        widget.mainKey.currentState!.setCode = message.setCode;
      });
    }else{
      widget.mainKey.currentState!.setCode = message.setCode;
    }

  }

  void setScore(String text) {
    if(mounted){
      setState(() {
        widget.mainKey.currentState!.score = text;
      });
    }else{
      widget.mainKey.currentState!.score = text;
    }
  }

  refreshReceivedScore(ViewerCaravanScoreMessage message){
    setState(() {
      if(message.setCode==widget.mainKey.currentState!.setCode){
        setScore("El puntaje recibido es "+message.score.toString());
        widget.caravanDiagramKey.currentState?.addNewSetCode(widget.mainKey.currentState!.setCode, message.score);


      }
    });
    if(mounted) {
      setCaravans(3);
    }
  }

  void setCaravans(int retry) {
    if(retry>0) {
      widget._diagramClientHttp.getCaravanChart(context,widget.mainKey.currentState!.identification).then((value)
          {
            if (value == null) {
              sleep(const Duration(milliseconds: 1000));
              setCaravans(retry - 1);
            }else{
              widget.caravanDiagramKey.currentState?.setCaravanDiagram(widget.mainKey.currentState!.setCode,value);
            }
        }
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    widget.viewerStompClient.refreshCaravan=refreshCalculatedScore;
    widget.viewerStompClient.refreshReceivedScore=refreshReceivedScore;
    return Column(
        children: [
          Text(widget.mainKey.currentState!.identification),
          Container(
            height: 250,
            width: 250,
            child: FittedBox(
              child: MyImage(widget.mainKey.currentState!.imageProvider),
              fit: BoxFit.fill,
            )
          ),
          Text(widget.mainKey.currentState!.score),
          CaravanLineChart(widget.caravanDiagramKey,widget.mainKey),
        ],
      );
  }






  @override
  void initState() {
    super.initState();
   setScore(widget.mainKey.currentState!.score);
    setIdentification(widget.mainKey.currentState!.identification);
    setImageProvider(widget.mainKey.currentState!.imageProvider);
    setScore(widget.mainKey.currentState!.score);
    setCaravans(3);

  }

  @override
  void dispose() {
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
