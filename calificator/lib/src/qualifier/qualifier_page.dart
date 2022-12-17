import 'package:calificator/src/qualifier/qualification_session_http.dart';
import 'package:calificator/src/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../menu/qualificator_side_menu.dart';
import '../ui_model/custom_text_button.dart';

class QualifierPage extends StatelessWidget{

  final User user;

  final String serverUrl;
  const QualifierPage(this.serverUrl,this.user,{Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: QualificationSideMenu(serverUrl),
        appBar: buildAppBar("Calificador - "+user.username),
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

  void showAlertDialog(BuildContext context,String message) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();

      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }

  /*
class _QualifierPageState extends State<QualifierPage> {



  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Text(widget._position.toString()),

      ],
    );
  }

  _QualifierPageState(){
    const duration = Duration(seconds: 10);


    Timer.periodic(duration, (Timer timer) {
      widget._client.nextJob(widget.user.username.toString()).then((response) => {
        if(response!=null && response.isNotEmpty){
          setState(() {
            if(response.containsKey("position")){
              widget._position=response.remove("position");
            }
          })
        }
      });
      /*setState(() {
        widget._position++;
        print(widget.user.username.toString()+" "+widget._position.toString());
      });*/

    });
  }
  */


   Future<User> _startQualificationSession(BuildContext context,String serverUrl,String userName) {
    var client=QualificationSessionHttp(serverUrl);
    return client.startSession("DEFAULT", userName);
  }

  Future<void> _endQualificationSession(BuildContext context,String serverUrl) {
    var client=QualificationSessionHttp(serverUrl);
    return client.endSession("DEFAULT");
  }
}
