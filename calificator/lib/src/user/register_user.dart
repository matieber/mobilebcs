import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/input_text.dart';
import 'package:calificator/src/user/register_client.dart';

import 'login_user.dart';

class RegisterUser extends MaterialPageRoute{



  RegisterUser(serverUrl): super(
      builder: (context) =>
          scaffold(RegisterUserHttp(serverUrl),context,serverUrl)
  );


    static Scaffold scaffold(RegisterUserHttp registerUserHttp, BuildContext context, serverUrl) {


    return Scaffold(
        appBar: buildAppBar("Registrar usuario"),
        body: UserNameInputText('Nombre de usuario',  loginCaller(registerUserHttp, context,serverUrl),)
        );

  }

  static AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,

    );
  }

    static ValueChanged<String> loginCaller(RegisterUserHttp registerUserHttp, BuildContext context, serverUrl) {
        return (String userName) {
          if(userName==""){
            showAlertDialog(context,"Se debe ingresar un nombre de usuario","Error al registrar usuario");
          }else{
            Future future = registerUserHttp.register(userName);
            future.whenComplete(() => print('Usuario registrado: ' + userName))
                .then((value) => Navigator.of(context).pop())
                .then((value) => Navigator.of(context).push(LoginUser(serverUrl)));
        }
          };
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

}
