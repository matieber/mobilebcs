import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import 'constants.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

enum RegisterStatus { notRegistered, tryingRegister }

class _RegisterState extends State<Register> {
  RegisterStatus _registerStatus = RegisterStatus.notRegistered;
  String name, email, mobile, password, confirmedPassword;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();
  final _key = new GlobalKey<FormState>();

  bool _registerRequestSent = false;

  bool _secureText = true;
  bool _confirmedSecureText = true;

  showHideConfirmed() {
    setState(() {
      _confirmedSecureText = !_confirmedSecureText;
    });
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  cantRegister() {
    setState(() {
      _registerStatus = RegisterStatus.notRegistered;
    });
  }

  check() {
    if (_registerRequestSent) {
      return;
    }
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  savePreferences(String email, String password, String fullName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool existingCredentials = preferences.getString("email") != null;
    if (!existingCredentials) {
        preferences.setString("full_name", fullName);
        preferences.setString("email", email);
        preferences.setString("password", password);
    }
  }

  save() async {
    var response;
    int value = 0;
    String message;
    try {
      _registerRequestSent = true;
      setState(() {
        _registerStatus = RegisterStatus.tryingRegister;
      });
      response = await http.post(AppURLConstants.registerURL, body: {
        "fullName": name,
        "email": email,
        "password": password,
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        message = LoginFormMessages.serverConnectionError;
      }
      else {
        final data = jsonDecode(response.body);
        value = data['value'];
        message = data['message'];
        if (value == 1) {
          savePreferences(email, password, name);
          Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => Login()),
          );
        } else {
          cantRegister();
        }
      }
    }
    on SocketException {
      message = LoginFormMessages.serverConnectionError;
      cantRegister();
    }
    on TimeoutException {
      message = LoginFormMessages.serverConnectionError;
      cantRegister();
    }
    finally {
      _registerRequestSent = false;
    }
    showToast(message, value);
  }

  Widget buildFullNameCard() {
    return Card(
      elevation: 6.0,
      child: TextFormField(
        autofocus: true,
        validator: (e) {
          if (e.isEmpty) {
            return LoginFormMessages.fullNameRequiredMessage;
          }
          return null;
        },
        onSaved: (e) => name = e,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(Icons.person, color: Colors.black),
            ),
            contentPadding: EdgeInsets.all(18),
            labelText: FormFieldNames.fullNameForm),
      ),
    );
  }

  Widget buildEmailCard() {
    return Card(
      elevation: 6.0,
      child: TextFormField(
        validator: (e) {
          if (e.isEmpty) {
            return LoginFormMessages.emailRequiredMessage;
          }
          if (!EmailValidator.validate(e)) {
            return LoginFormMessages.emailInvalidFormatMessage;
          }
          return null;
        },
        onSaved: (e) => email = e,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(Icons.email, color: Colors.black),
            ),
            contentPadding: EdgeInsets.all(18),
            labelText: FormFieldNames.emailForm),
      ),
    );
  }

  IconButton buildPasswordShowIcon(label) {
    if (label == FormFieldNames.passwordForm)
      return IconButton(
        onPressed: showHide,
        icon: Icon(_secureText
            ? Icons.visibility_off
            : Icons.visibility),
      );

      return IconButton(
        onPressed: showHideConfirmed,
        icon: Icon(_confirmedSecureText
            ? Icons.visibility_off
            : Icons.visibility),
      );
  }

  onShowHidePressed(label) {
    if (label == FormFieldNames.passwordForm)
      showHide();
    else
      showHideConfirmed();
  }

  Widget buildPasswordCard(controllerObject, validatorFunction, fieldSaveFunction, label) {
    return Card(
      elevation: 6.0,
      child: TextFormField(
        controller: controllerObject,
        validator: validatorFunction,
        obscureText: (label == FormFieldNames.passwordForm) ? _secureText: _confirmedSecureText,
        onSaved: fieldSaveFunction,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
            suffixIcon: buildPasswordShowIcon(label),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(Icons.phonelink_lock,
                  color: Colors.black),
            ),
            contentPadding: EdgeInsets.all(18),
            labelText: label),
      ),
    );
  }

  String passwordValidationFunction(String e) {
    if (e.isEmpty) {
      return LoginFormMessages.passwordRequiredMessage;
    }
    String pVal = passwordController.value.text;
    String cPVal = confirmedPasswordController.value.text;
    if (pVal != cPVal) {
      return LoginFormMessages.passwordDoesNotMatchMessage;
    }
    return null;
  }

  Widget buildBottomButtonRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          height: 44.0,
          child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                FormFieldNames.registerActionButtonForm,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                check();
              }),
        ),
        SizedBox(
          height: 44.0,
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                FormFieldNames.gotoLoginButtonForm,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Login()),
                );
              }),
        ),
      ],
    );
  }

  Widget buildNotRegisteredScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).backgroundColor,
                child: Form(
                  key: _key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                          AppURLConstants.mainImageURL),
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        height: 50,
                        child: Text(
                          FormScreenTitle.registerFormTitle,
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),

                      //card for Fullname TextFormField
                      buildFullNameCard(),
                      //card for Email TextFormField
                      buildEmailCard(),
                      //card for Password TextFormField
                      buildPasswordCard(passwordController, passwordValidationFunction, (e) => password = e, FormFieldNames.passwordForm),
                      //card for Password confirmation TextFormField
                      buildPasswordCard(confirmedPasswordController, passwordValidationFunction, (e) => confirmedPassword = e, FormFieldNames.confirmedPasswordForm),

                      Padding(
                        padding: EdgeInsets.all(12.0),
                      ),

                      buildBottomButtonRow(),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTryingRegisterScreen() {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_registerStatus) {
      case RegisterStatus.notRegistered:
        return buildNotRegisteredScreen();
        break;

      case RegisterStatus.tryingRegister:
        return buildTryingRegisterScreen();
        break;
    }
  }

  Widget _buildMobilePhoneCard() {
    return
      //card for Mobile TextFormField
      Card(
        elevation: 6.0,
        child: TextFormField(
          validator: (e) {
            if (e.isEmpty) {
              return LoginFormMessages.mobilePhoneRequiredMesage;
            }
            return null;
          },
          onSaved: (e) => mobile = e,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20, right: 15),
              child: Icon(Icons.phone, color: Colors.black),
            ),
            contentPadding: EdgeInsets.all(18),
            labelText: FormFieldNames.mobilePhoneForm,
          ),
          keyboardType: TextInputType.number,
        ),
      );

  }
}