import 'dart:typed_data';
import 'dart:convert';

import 'package:time_machine/time_machine.dart';

class PredictionResponse{


  final int? qualificationSession;
  final String? sessionStartDate;
  final String? sessionEndDate;
  final List<ScoreResponse> scores;
  final int caravanSize;

  PredictionResponse(this.qualificationSession, this.sessionStartDate,
      this.sessionEndDate,
      this.scores,
      this.caravanSize,
      );

  PredictionResponse.fromJson(Map<String, dynamic> json):
      qualificationSession=json["qualificationSession"],
      sessionStartDate=json["sessionStartDate"],
      sessionEndDate= json["sessionEndDate"],
      caravanSize=json["caravanSize"],
      scores=convert(json);

  static List<ScoreResponse> convert(Map<String,dynamic> json) {
    var values = json['scores'];
    if(values!=null) {
      return (values as List)
          .map((e) => e as Map<String,dynamic>)
          .map((e) => ScoreResponse.fromJson(e))
          .toList();

    }else{
      return List.empty();
    }
  }

}


class ScoreResponse{

  double value;

  ScoreResponse(this.value);

  ScoreResponse.fromJson(Map<String, dynamic> json):
        value=json["value"];
}