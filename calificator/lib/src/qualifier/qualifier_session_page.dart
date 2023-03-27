import 'package:calificator/src/qualifier/qualification_session_http.dart';
import 'package:calificator/src/qualifier/qualifier_page.dart';
import 'package:calificator/src/ui_model/extension.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../menu/qualificator_side_menu.dart';
import '../ui_model/alert.dart';
import '../ui_model/custom_text_button.dart';

class QualifierSessionPage extends StatelessWidget{

  final User user;

  final String serverUrl;
  const QualifierSessionPage(this.serverUrl,this.user,{Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: QualificationSideMenu(serverUrl),
        appBar: buildAppBar(user.userType.value.capitalize()+" - "+user.username),
        body:  buildBody(context)
    );
  }

  Widget? buildBody(BuildContext context){
    return Center(
          child: Container(
          color: Colors.lightGreen.shade100,
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: CustomTextButton('Iniciar sesión de calificación',
                        voidFunction: (){
                          Future<User> future=_startQualificationSession(context,serverUrl,user.username);
                          future.then((userResponse) =>user.qualificationSession=userResponse.qualificationSession)
                          .then((value) => print("Id de la sesión de calificación "+user.qualificationSession.toString()))
                          .then((value) => showAlertDialog(context, "La sesión de calificación ha comenzado correctamente"))
                          .then((value) =>
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context)=> QualifierPage(this.user,serverUrl))
                              )
                          )
                          .onError((error, stackTrace) => showAlertDialog(context, error.toString()));
                    })
                ),
                const SizedBox(height: 100),
                Container(
                    child: CustomTextButton('Finalizar sesión de calificación',
                        voidFunction: (){
                          Future<void> future=_endQualificationSession(context,serverUrl);
                          future
                              .then((value) => showAlertDialog(context, "Finalizó la sesión de calificación correctamente"))
                              .onError((error, stackTrace) => showAlertDialog(context, error.toString()));
                        })
                ),
              ]

          ),
        )
      );

  }



  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }


   Future<User> _startQualificationSession(BuildContext context,String serverUrl,String userName) {
    var client=QualificationSessionHttp(serverUrl);
    return client.startSession("DEFAULT", userName);
  }

  Future<void> _endQualificationSession(BuildContext context,String serverUrl) {
    var client=QualificationSessionHttp(serverUrl);
    return client.endSession("DEFAULT");
  }
}
