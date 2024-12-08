import 'dart:convert';
import 'dart:async';
import 'package:calificator/src/diagram/prediction_response.dart';
import 'package:calificator/src/settings/properties.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'caravan_response.dart';
import 'diagram_response.dart';


class DiagramClientHttp  {



  Future<DiagramResponse?> getCurrentPrediction(BuildContext context,String searchType) async{

    return Properties.getHttpServerUrl(context).then((_serverUrl) async {
      String endpointUrl=_serverUrl+"/prediction?location=DEFAULT&searchType="+searchType;
      Uri uri=Uri.parse(endpointUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody=json.decode(response.body);
        return DiagramResponse.fromJson(responseBody);
      }else{
        if(response.statusCode == 204){
          return null;
        }
      }
    });

  }

  Future<PredictionResponse?> getPrediction(BuildContext context,String qualificationSessionId) async{

    return Properties.getHttpServerUrl(context).then((_serverUrl) async {
      String endpointUrl=_serverUrl+"/prediction/"+qualificationSessionId;
      Uri uri=Uri.parse(endpointUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody=json.decode(response.body);
        return PredictionResponse.fromJson(responseBody);
      }else{
        if(response.statusCode == 204){
          return null;
        }
      }
    });

  }

  Future<CaravanInfoResponse?> getCaravanChart(BuildContext context,String identification) async{

    return Properties.getHttpServerUrl(context).then((_serverUrl) async {
      String endpointUrl = _serverUrl + "/caravan/" + identification;
      Uri uri = Uri.parse(endpointUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return CaravanInfoResponse.fromJson(responseBody);
      } else {
        if (response.statusCode == 204) {
          return null;
        }
      }
    });
  }


}