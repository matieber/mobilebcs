import 'dart:convert';
import 'dart:async';
import 'package:calificator/src/user/user.dart';
import 'package:http/http.dart' as http;

class LoginUserHttp  {


  final String _serverUrl;


  LoginUserHttp(this._serverUrl);

  Future<User> login(String userName) async{


    String endpointUrl=_serverUrl+'/user/${userName}';
    Uri uri=Uri.parse(endpointUrl);
    final response = await http.post(uri);
    if (response.statusCode == 201) {
      final responseBody=json.decode(response.body);
      return User.fromJson(responseBody);
    }else{
      if (response.statusCode == 404) {
        print('statusCode ${response.statusCode} y error: ${response.body}');
        return Future.error("El usuario ingresado es inexistente");
      } else {
        print('statusCode ${response.statusCode} y error: ${response.body}');
        return Future.error("Error inesperado al ingresar usario");
      }
    }
  }


}