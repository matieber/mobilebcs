import 'package:calificator/src/user/user.dart';
import 'package:calificator/src/user/userClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calificator/src/current_page.dart';
import '../ui_model/input_text.dart';

class LoginUser extends StatefulWidget{

  final double _width;
  final UserHttp _client;
  final CurrentPage _currentPage;
  final User user;


  LoginUser(this._width, this._client,this._currentPage, this.user);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  @override
  Widget build(BuildContext context) {
    var onSubmitted = (String userName){
      print('Usuario Ingresado: '+userName);

      widget._client.login(userName).then((response) => {
        if(response!=null && response.isNotEmpty){
          redirect(userName)
        }
      });
    };
    return Column(
      children: [
        UserNameInputText(widget._width,'Nombre de usuario', onSubmitted),
      ],
    );
  }

  redirect(String userName) {
    widget.user.username=userName;
    widget._currentPage.toQualifierPage();
  }
}