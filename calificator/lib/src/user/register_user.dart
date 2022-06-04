import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui_model/icon_button.dart';
import '../ui_model/input_text.dart';

class RegisterUser extends StatefulWidget{

  final double _width;

  RegisterUser(this._width);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {

  @override
  Widget build(BuildContext context) {


    var onSubmitted = (String value){print('Usuario registrado: '+value);};

    return Column(
      children: [
        UserNameInputText(widget._width,'Nombre de usuario', onSubmitted,)

      ],
    );
  }


}
