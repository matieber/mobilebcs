import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class UserHttp  {


  final String _serverIp;
  final int _serverPort;


  UserHttp(this._serverIp, this._serverPort);

  Future<Map<String,dynamic>?> login(String userName) async{


    Uri uri=Uri(scheme: 'http',host: _serverIp,port: _serverPort,path: '/user/'+userName);
    print("url "+uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody=json.decode(response.body);
      print(responseBody);
      return responseBody;
    }else{
      if(response.statusCode == 204){
        return null;
      }else {
        if (response.statusCode == 404) {
          throw Exception("Usuario no existe");
        } else {
          throw Exception('Failed to get file');
        }
      }
    }
  }


}