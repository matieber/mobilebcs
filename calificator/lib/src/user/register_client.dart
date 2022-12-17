import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class RegisterUserHttp  {


  final String _serverUrl;


  RegisterUserHttp(this._serverUrl);

  Future register(String userName) async{


    String endpointUrl=_serverUrl+"/user";
    final request = '{"userType": "QUALIFIER", "userName": "$userName"}';
    Uri uri=Uri.parse(endpointUrl);
    print("url "+uri.toString());

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