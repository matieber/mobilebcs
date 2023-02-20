import 'package:calificator/src/qualifier/qualifier_session_page.dart';
import 'package:calificator/src/qualifier/viewer_page.dart';
import 'package:calificator/src/user/login_user_http.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui_model/input_text.dart';

class LoginUser extends MaterialPageRoute {



  LoginUser(String serverUrl) : super(

      builder: (context) =>
      scaffold(LoginUserHttp(serverUrl),context,serverUrl)
  );

  static Scaffold scaffold(LoginUserHttp loginUserHttp, BuildContext context, String serverUrl) {
    return Scaffold(
        appBar: buildAppBar("Ingresar usuario"),
        body: UserNameInputText('Nombre de usuario', (String userName) {
    if(userName==""){
      showAlertDialog(context,"Se debe ingresar un nombre de usuario","Error al ingresar usuario");
    }else{
      Future<User> future=loginUserHttp.login(userName);
      future.then((user) {
      print('Usuario Ingresado: ${user}');
      return user;})
          .then((user) {
      Navigator.of(context).pop();
      return user;
      }).then((user)=>

           Navigator.of(context)
              .pushReplacement(
              MaterialPageRoute(builder:
              (context) {
                if (user.userType == UserType.qualifier) {
                  return QualifierSessionPage(serverUrl, user);
                }else{
                  return ViewerPage(user, serverUrl);
                }
              }
          )
          )
      )
          .onError((error, stackTrace) => showAlertDialog(context,error!,"Error al ingresar usuario"));
    }
        }
        )
    );
  }

  static void showAlertDialog(BuildContext context, Object error,String text) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();

        },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(text),
      content: Text(error.toString()),
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

  static AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }


}



  /*
  redirect(String userName) {
    widget.user.username=userName;
    widget._currentPage.toQualifierPage();
  }
  */

