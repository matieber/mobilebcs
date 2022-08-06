import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ClientHttp  {


  final String _serverIp;
  final int _serverPort;


  ClientHttp(this._serverIp, this._serverPort);

  Future<Map<String,dynamic>> getFile(String userName) async{


    Uri uri=Uri(scheme: 'http',host: _serverIp,port: _serverPort,path: '/user/'+userName);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody=json.decode(response.body);
      print(responseBody);
      return responseBody;
    }else{
      if(response.statusCode == 404){
        throw Exception("Usuario no existe");
      }else {
        throw Exception('Failed to get file');
      }
    }
  }


}