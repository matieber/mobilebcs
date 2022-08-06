import 'package:calificator/src/client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui_model/input_text.dart';

class LoginUser extends StatefulWidget{

  final double _width;
  final ClientHttp _client;


  LoginUser(this._width, this._client);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  @override
  Widget build(BuildContext context) {
    var onSubmitted = (String userName){
      print('Usuario Ingresado: '+userName);

      widget._client.getFile(userName).then((response) => print(response));
    };
    return Column(
      children: [
        UserNameInputText(widget._width,'Nombre de usuario', onSubmitted),
      ],
    );
  }
}