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
    return Container(
        child: Center(
          child: Text("Cargando..."),
        ),
      );
  }

}
