import 'dart:convert';
import 'dart:async';
import 'package:calificator/src/settings/properties.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class DeviationDiagramClientHttp  {



  Future<DispersionResponse?> getDispersion(BuildContext context) async{

    return Properties.getHttpServerUrl(context).then((_serverUrl) async {
      String endpointUrl=_serverUrl+"/prediction/dispersion?location=DEFAULT&amount=5";
      Uri uri=Uri.parse(endpointUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody=json.decode(response.body);
        return DispersionResponse.fromJson(responseBody);
      }else{
        if(response.statusCode == 204){
          return null;
        }
      }
    });

  }

}

class DispersionResponse{

  final List<QualifierSessionAverageResponse> values;

  DispersionResponse(this.values);

  DispersionResponse.fromJson(Map<String,dynamic> json):
        values = convert(json);

  static List<QualifierSessionAverageResponse> convert(Map<String,dynamic> json) {
    var values = json['values'];
    if(values!=null) {
      return (values as List)
          .map((e) => e as Map<String,dynamic>)
          .map((e) => QualifierSessionAverageResponse.fromJson(e))
          .toList();

    }else{
      return List.empty();
    }
  }

  @override
  String toString() {
    return 'DispersionResponse{values: $values}';
  }
}

class QualifierSessionAverageResponse{


  final int qualificationSession;
  final String? sessionStartDate;
  final String? sessionEndDate;
  final double average;
  final double stardardDeviation;

  QualifierSessionAverageResponse(this.qualificationSession, this.sessionStartDate,
      this.sessionEndDate,
      this.average,
      this.stardardDeviation,
      );

  QualifierSessionAverageResponse.fromJson(Map<String, dynamic> json):
        qualificationSession=json["qualificationSession"],
        sessionStartDate=json["sessionStartDate"],
        sessionEndDate= json["sessionEndDate"],
        average=json["average"],
        stardardDeviation=json["standardDeviation"];

  @override
  String toString() {
    return 'QualifierSessionAverageResponse{qualificationSession: $qualificationSession, sessionStartDate: $sessionStartDate, sessionEndDate: $sessionEndDate, average: $average, stardardDeviation: $stardardDeviation}';
  }
}