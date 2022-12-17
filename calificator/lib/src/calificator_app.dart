import 'dart:convert';


import 'dart:io';
import 'package:calificator/src/user/user_page.dart';
import 'package:flutter/material.dart';
/// The Widget that configures your application.
class CalificatorApp extends StatefulWidget {

  const CalificatorApp({Key? key}) : super(key: key);


  
  @override
  State<CalificatorApp> createState() => _CalificatorAppState();
}

class _CalificatorAppState extends State<CalificatorApp> {



  @override
  Widget build(BuildContext context) {



    return  Scaffold(
        body: FutureBuilder<String>(
          future: getServerUrl(context),
          builder:(BuildContext context,AsyncSnapshot<String> snapshot){
            if(!snapshot.hasData){
              return buildLoading();
            }else{
              return UserPage(snapshot.data.toString());
            }
          } ,
        )
    );

   /* return  Scaffold(
                appBar: buildAppBar(),
                drawer: SideMenu(_currentPage),
                body:
                _width == 0 && _serverIp== "" && _serverPort==0 ?
                buildLoading(): buildBody()
    );*/
  }

  Future<String> getServerUrl(BuildContext context) {
      return DefaultAssetBundle.of(context).loadString('assets/my_config.json')
        .then((jsonString){
        dynamic jsonMap=jsonDecode(jsonString);
        String serverUrl=jsonMap['serverUrl'];
        if(serverUrl==""){
          if (Platform.isAndroid) {
            serverUrl="http://10.0.2.2:8080";
          } else if (Platform.isIOS) {
            serverUrl="http://localhost:8080";
          }
        }
        return serverUrl;
      }
    );
  }

  Container buildLoading() {
    getWidth(context).then((double value) => setState(
        () {


        }
    ));
    getHeight(context).then((double value) => setState(
            () {


        }
    ));
    return Container(
        child: Center(
          child: Text("Cargando..."),
        ),
      );
  }
  
  Future<double> getWidth(BuildContext context) async {
    await MediaQuery.of(context).size.width > 0;
    print('Obtenido '+MediaQuery.of(context).size.width.toString());
    return MediaQuery.of(context).size.width;
  }

  Future<double> getHeight(BuildContext context) async {
    await MediaQuery.of(context).size.height > 0;
    print('Obtenido '+MediaQuery.of(context).size.height.toString());
    return MediaQuery.of(context).size.height;
  }



}
