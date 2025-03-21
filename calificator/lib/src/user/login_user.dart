import 'package:calificator/src/qualifier/qualifier_session_page.dart';
import 'package:calificator/src/viewer/viewer_page.dart';
import 'package:calificator/src/user/login_user_http.dart';
import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui_model/input_text.dart';
import '../viewer/viewer_page_main.dart';

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
                  var newPage = ViewerPageMain.newPage(serverUrl);
                  newPage.user=user;
                  return newPage;
                }
              }
          )
          )
      )
          .onError((error, stackTrace) {
            var message = error.toString() == "Connection refused"? "Error de connexión": error!;
            return showAlertDialog(context,message,"Error al ingresar usuario");
          });
    }
        }
        )
    );
  }

  static void showAlertDialog(BuildContext context, Object error,String text) {

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();

        },
    );

    AlertDialog alert = AlertDialog(
      title: Text(text),
      content: Text(error.toString()),
      actions: [
        okButton,
      ],
    );

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


