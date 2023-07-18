import 'dart:convert';


import 'dart:io';
import 'package:calificator/src/settings/properties.dart';
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
          future: Properties.getHttpServerUrl(context),
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



  Container buildLoading() {
    return Container(
        child: Center(
          child: Text("Cargando..."),
        ),
      );
  }

}
