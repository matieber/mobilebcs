import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui_model/input_text.dart';

class LoginUser extends StatefulWidget{

  final double _width;

  LoginUser(this._width);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  @override
  Widget build(BuildContext context) {
    var onSubmitted = (String value){print('Usuario Ingresado: '+value);};
    return Column(
      children: [
        UserNameInputText(widget._width,'Nombre de usuario', onSubmitted),
      ],
    );
  }
}