import 'dart:async';
import 'package:calificator/src/user/user_type.dart';
import 'package:http/http.dart' as http;

class RegisterUserHttp  {


  final String _serverUrl;


  RegisterUserHttp(this._serverUrl);

  Future register(String userName,UserType userType) async{


    String userTypeValue=userType.name.toUpperCase();
    String endpointUrl=_serverUrl+"/user";
    final request = '{"userType": "$userTypeValue", "userName": "$userName"}';
    Uri uri=Uri.parse(endpointUrl);

    Map<String,String> map={};
    map.putIfAbsent("Content-Type", () => "application/json");
    final response = await http.post(uri,headers: map,body: request);
    if (response.statusCode == 201) {
      return null;
    }else{
        if (response.statusCode == 400) {
          throw Exception(response.body);
        } else {
          throw Exception('Error inesperado con estado ${response.statusCode}');
        }
    }
  }


}