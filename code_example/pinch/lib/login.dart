import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:apinch/services/connectionHandler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import 'package:apinch/services/wifi/apinchwifi.dart';
import 'package:apinch/locator_service.dart' as di;
import 'main.dart';
import 'register.dart';
import 'wait_network.dart';
import 'navigation_tab.dart';
import 'constants.dart';
import 'package:apinch/services/wifi/connectivity_status.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus {
  withoutWifi,
  notSignIn,
  signIn,
  tryingSignIn,
  enteringRedeemCode,
}

showToast(String toast, int success /* 1 success, 0 error */) {
  if (toast.isNotEmpty) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: (success == 1) ? Colors.green : Colors.red,
        textColor: Colors.white);
  }
}

class _LoginState extends State<Login> {
  //LoginStatus _loginStatus = LoginStatus.withoutWifi;
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String email, password, redeemCode = '';
  final _key = new GlobalKey<FormState>();
  TextEditingController _myEmailController = TextEditingController();
  TextEditingController _myPasswordController = TextEditingController();
  TextEditingController _myRedeemCodeController = TextEditingController();
  WebViewController _webViewcontroller;

  FocusNode _myFocusNode;
  FocusNode _reedemCodeFocus;

  bool _loginRequestSent = false;
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    if (_loginRequestSent) {
      return;
    }
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  cantSignIn() {
    setState(() {
      if (redeemCode?.isNotEmpty)
        _loginStatus = LoginStatus.enteringRedeemCode;
      else
        _loginStatus = LoginStatus.notSignIn;
    });
  }

  notSignIn() {
    setState(() {
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  withOutWifi() {
    setState(() {
      _loginStatus = LoginStatus.withoutWifi;
    });
  }

  login() async {
    final logger = di.sl<Logger>();
    var response;
    int value = 0;
    String message;
    logger.d("Inicio de Login");
    try {
      _loginRequestSent = true;
      setState(() {
        _loginStatus = LoginStatus.tryingSignIn;
      });

      final loginjson = {
        "email": email,
        "password": password,
        "redeemCode": redeemCode ?? "",
      };

      logger.d("Inicio de http.post Login: $loginjson");
      response = await http
          .post(AppURLConstants.loginURL, body: loginjson)
          .timeout(Duration(seconds: 10));
      final data = jsonDecode(response.body);
      value = data['value'];
      message = data['message'];
      String fullNameFromAPI = data['fullName'];

      // Login successful
      if (value == 1) {
        logger.d("Fin de http Login con exito");
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("full_name", fullNameFromAPI);
        preferences.setString("email", email);
        preferences.setString("password", password);
        preferences.commit();

        //await di.sl<APinchConnectivityService>().autentificate();

        final idSession =
            await di.sl<APinchConnectivityService>().getSessionId();

        //autentificacion fas con el id de sesion
        var endpointUrl = ServiceURLConstants.FAS_URL+'/fas/$idSession/auth';
        logger.d("Inicio de auth fas: $endpointUrl");
        _webViewcontroller.loadUrl(endpointUrl);

        setState(() {
          _loginStatus = LoginStatus.signIn;
        });
      } else {
        cantSignIn();
      }
    } on SocketException {
      logger.d("Fin de http Login con Exception");
      message = LoginFormMessages.serverConnectionError;
      cantSignIn();
    } on TimeoutException {
      logger.d("Fin de http Login con TimeoutException");
      message = LoginFormMessages.serverConnectionError;
      cantSignIn();
    } finally {
      _loginRequestSent = false;
    }
    showToast(message, value);
  }

  readSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    email = preferences.getString("email");
    password = preferences.getString("password");
    _myEmailController.text = email;
    _myPasswordController.text = password;
  }

  signOut() async {
    setState(() {
      _loginStatus = LoginStatus.withoutWifi;
    });
  }

  @override
  void initState() {
    super.initState();
    readSharedPreferences();
    _myFocusNode = new FocusNode();
    _reedemCodeFocus = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _myEmailController.dispose();
    _myPasswordController.dispose();
    _myRedeemCodeController.dispose();
    di.sl<APinchConnectivityService>().dispose();
  }

  Widget buildEmailCard() {
    return Card(
      elevation: 6.0,
      child: TextFormField(
        autofocus: true,
        controller: _myEmailController,
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
              child: Icon(Icons.person, color: Colors.black),
            ),
            contentPadding: EdgeInsets.all(18),
            labelText: FormFieldNames.emailForm),
      ),
    );
  }

  Widget buildPasswordCard() {
    return Card(
      elevation: 6.0,
      child: TextFormField(
        controller: _myPasswordController,
        validator: (e) {
          if (e.isEmpty) {
            return LoginFormMessages.passwordRequiredMessage;
          }
          return null;
        },
        obscureText: _secureText,
        onSaved: (e) => password = e,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          labelText: FormFieldNames.passwordForm,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20, right: 15),
            child: Icon(Icons.phonelink_lock, color: Colors.black),
          ),
          suffixIcon: IconButton(
            onPressed: showHide,
            icon: Icon(_secureText ? Icons.visibility_off : Icons.visibility),
          ),
          contentPadding: EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        showToast("Funcionalidad no implementada", 0);
      },
      child: Text(
        LoginFormMessages.forgotPasswordMessage,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildRedeemCode() {
    if (_loginStatus == LoginStatus.enteringRedeemCode) {
      return buildRedeemCodeCard();
    } else
      return TextButton(
        onPressed: () {
          setState(() {
            _loginStatus = LoginStatus.enteringRedeemCode;
          });
        },
        child: Text(
          LoginFormMessages.enterRedeemCodeLabel,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
  }

  Widget buildRedeemCodeCard() {
    Widget w = Card(
      elevation: 6.0,
      child: TextFormField(
        enabled: true,
        enableInteractiveSelection: true,
        focusNode: _reedemCodeFocus,
        controller: _myRedeemCodeController,
        validator: (e) {
          if (e.isEmpty) {
            return LoginFormMessages.emptyRedeemCodeMessage;
          }
          return null;
        },
        onSaved: (e) {
          redeemCode = e;
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          labelText: FormFieldNames.redeemCodeForm,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20, right: 15),
            child: Icon(Icons.wb_iridescent_outlined, color: Colors.black),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _myRedeemCodeController.clear();
                _loginStatus = LoginStatus.notSignIn;
              });
            },
            icon: Icon(Icons.cancel),
          ),
        ),
      ),
    );
    FocusScope.of(context).requestFocus(_reedemCodeFocus);
    return w;
  }

  Widget buildBottomButtonRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          height: 44.0,
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                FormFieldNames.loginActionButtonForm,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              color: Theme.of(context).accentColor,
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
                FormFieldNames.gotoRegisterButtonForm,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              }),
        ),
      ],
    );
  }

  Widget buildTryingSignInScreen(BuildContext context) {
    return WillPopScope(
        onWillPop: () => MyApp.onBackPressed(context),
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            //body: Center(child: CircularProgressIndicator())));
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Center(child: CircularProgressIndicator()),
                  //este webview se usa para forzar la creacion de una sesion por eso se muestra de 1 pixel para que no se vea
                  Container(
                      height: 1,
                      width: 1,
                      child: WebView(
                        initialUrl: 'http://3.129.56.198/demo/',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _webViewcontroller = webViewController;
                        },
                      ))
                ]))));
  }

  Widget buildNotSignedInScreen(BuildContext context) {
    return WillPopScope(
        onWillPop: () => MyApp.onBackPressed(context),
        child: Scaffold(
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
                          Image.asset(AppURLConstants.mainImageURL),
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            height: 50,
                            child: Text(
                              FormScreenTitle.loginFormTitle,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 30.0),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),

                          // Card for Email TextFormField
                          buildEmailCard(),

                          // Card for password TextFormField
                          buildPasswordCard(),

                          buildRedeemCode(),

                          SizedBox(
                            height: 12,
                          ),

                          buildForgotPasswordButton(),

                          Padding(
                            padding: EdgeInsets.all(14.0),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    final logger = di.sl<Logger>();
    logger.d("Login status before: $_loginStatus");
    var connectivityInfo = Provider.of<ConnectivityStatus>(context);
    logger.d("Connectivity status: $connectivityInfo");

    if (connectivityInfo != ConnectivityStatus.APinch) withOutWifi();

    switch (_loginStatus) {
      case LoginStatus.withoutWifi:
        return WaitNetworksPage(di.sl<APinchConnectivityService>(), notSignIn);
      case LoginStatus.notSignIn:
        return buildNotSignedInScreen(context);
        break;

      case LoginStatus.enteringRedeemCode:
        return buildNotSignedInScreen(context);
        break;

      case LoginStatus.tryingSignIn:
        return buildTryingSignInScreen(context);
        break;

      case LoginStatus.signIn:
        return MainMenu(signOut);
        break;
    }
  }
}
