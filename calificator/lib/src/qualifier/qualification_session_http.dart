import 'dart:convert';
import 'dart:async';
import 'package:calificator/src/user/user.dart';
import 'package:http/http.dart' as http;

class QualificationSessionHttp  {


  final String _serverUrl;


  QualificationSessionHttp(this._serverUrl);

  Future<User> startSession(String location,String userName) async{


    String endpointUrl=_serverUrl+'/location/${location}/user/${userName}/qualificationSession';
    Uri uri=Uri.parse(endpointUrl);
    print("url "+uri.toString());
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final responseBody=json.decode(response.body);
      print(responseBody);
      return User.fromJson(responseBody);
    }else{
      if (response.statusCode == 404) {
        print('statusCode ${response.statusCode} y error: ${response.body}');
        return Future.error('${response.body}');
      } else {
        if (response.statusCode == 400) {
          print('statusCode ${response.statusCode} y error: ${response.body}');
          return Future.error('${response.body}');
        }else {
          print('statusCode ${response.statusCode} y error: ${response.body}');
          return Future.error("Error inesperado al iniciar sesión de calificación");
        }
      }
    }
  }

  Future<void> endSession(String location) async{


    String endpointUrl=_serverUrl+'/location/${location}/qualificationSession';
    Uri uri=Uri.parse(endpointUrl);
    print("url "+uri.toString());
    final response = await http.delete(uri);
    if (response.statusCode == 204) {
      return Future.value(null);
    }else{
      if (response.statusCode == 404) {
        print('statusCode ${response.statusCode} y error: ${response.body}');
        return Future.error('${response.body}');
      } else {
        if (response.statusCode == 400) {
          print('statusCode ${response.statusCode} y error: ${response.body}');
          return Future.error('${response.body}');
        }else {
          print('statusCode ${response.statusCode} y error: ${response.body}');
          return Future.error("Error inesperado al finalizar sesión de calificación");
        }
      }
    }
  }


}