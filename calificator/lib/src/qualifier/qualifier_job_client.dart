import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'next_caravan_message.dart';

class Qualify{

  final int score;

  Qualify(this.score);

}


class QualifierJobClientHttp  {


  final String _serverUrl;


  QualifierJobClientHttp(this._serverUrl);


  void qualify(String userName,String setCode, int score) async{

    String endpointUrl=_serverUrl+"/qualifier/"+userName+"/setCode/"+setCode;
    Uri uri=Uri.parse(endpointUrl);
    final body = '{"score": $score}';
    Map<String,String> map={};
    map.putIfAbsent("Content-Type", () => "application/json");
    final response = await http.put(uri,body: body,headers: map);

    if(response.statusCode == 204){
      return null;
    }else {
      if (response.statusCode == 404) {
        throw Exception("Usuario no existe");
      } else {
        throw Exception('Error al calificar');
      }
    }

  }

  Future<CaravanMessage?> nextJob(String userName) async{

   String endpointUrl=_serverUrl+"/qualifier/"+userName+"/next-animal";
    Uri uri=Uri.parse(endpointUrl);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseBody=json.decode(response.body);
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