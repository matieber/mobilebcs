import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class QualifierHttp  {


  final String _serverIp;
  final int _serverPort;


  QualifierHttp(this._serverIp, this._serverPort);

  Future<Map<String,dynamic>?> nextJob(String userName) async{

   print("getting next job");
    Uri uri=Uri(scheme: 'http',host: _serverIp,port: _serverPort,path: '/qualifier/'+userName+"/next-animal");
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