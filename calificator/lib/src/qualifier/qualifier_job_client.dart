import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'next_caravan_message.dart';

class QualifierJobClientHttp  {


  final String _serverUrl;


  QualifierJobClientHttp(this._serverUrl);

  Future<CaravanMessage?> nextJob(String userName) async{

   print("getting next job");
   String endpointUrl=_serverUrl+"/qualifier/"+userName+"/next-animal";
    Uri uri=Uri.parse(endpointUrl);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody=json.decode(response.body);
      print(responseBody);
      return CaravanMessage.fromJson(responseBody);
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