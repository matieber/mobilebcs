import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/input_text.dart';
import 'package:calificator/src/user/register_client.dart';

import 'drowpdown_type.dart';
import 'login_user.dart';

class RegisterUser extends StatefulWidget {
  String serverUrl;


  RegisterUser(this.serverUrl);


  @override
  State<RegisterUser> createState() => _RegisterUserState();


}

class _RegisterUserState extends State<RegisterUser> {

  UserType userType=UserType.qualifier;
  @override
  Widget build(BuildContext context) {
    return scaffold(RegisterUserHttp(widget.serverUrl), context, widget.serverUrl);
  }


  refresh(UserType userType) {
    setState(() {
      this.userType=userType;
    });
  }

   Scaffold scaffold(
      RegisterUserHttp registerUserHttp, BuildContext context, serverUrl) {


    DropdownType dropdownType = DropdownType(notifyParent: refresh);
    return Scaffold(
        appBar: buildAppBar("Registrar usuario"),
        body: Center(
            child: Container(
          color: Colors.lightGreen.shade100,
          width: double.infinity,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                child: UserNameInputText(
              'Nombre de usuario',
              registerCaller(registerUserHttp, context, serverUrl,userType),
            )),
            Container(
              child: Row(
                children: [
                  const Text("Tipo de usuario"),
                  const Text("  "),
                  Container(
                    child: dropdownType,
                  )
                ],
              ),
            )
          ]),
        )));
  }

  ValueChanged<String> registerCaller(
      RegisterUserHttp registerUserHttp, BuildContext context, serverUrl,UserType userType) {
    return (String userName) {
      if (userName == "") {
        showAlertDialog(context, "Se debe ingresar un nombre de usuario",
            "Error al registrar usuario");
      } else {
        Future future = registerUserHttp.register(userName,userType);
        future
            .whenComplete(() => print('Usuario registrado: ' + userName))
            .then((value) => Navigator.of(context).pop())
            .then((value) => Navigator.of(context).push(LoginUser(serverUrl)));
      }
    };
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.green,
    );
  }

  void showAlertDialog(BuildContext context, Object error, String text) {
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
