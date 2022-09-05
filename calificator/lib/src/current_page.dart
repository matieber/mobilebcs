
import 'package:flutter/material.dart';

class CurrentPage{


  final VoidCallback _homeFunction;
  final VoidCallback _settingFunction;
  final VoidCallback _loginUserFunction;
  final VoidCallback _registerUserFunction;
  final VoidCallback _qualifierPage;
  String? username="";

  CurrentPage(this._homeFunction,this._settingFunction,this._loginUserFunction,this._registerUserFunction,this._qualifierPage);



  toHome(){
    _homeFunction();
  }

  toSetting(){
    _settingFunction();
  }

  toLoginUser(){
    _loginUserFunction();
  }

  toRegisterUser(){
    _registerUserFunction();
  }

  toQualifierPage() {
    _qualifierPage();
  }



}