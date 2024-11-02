
import 'package:time_machine/time_machine.dart';

class CaravanInfoResponse{



  final List<CaravanQualificationResponse> list;

  CaravanInfoResponse(this.list);

  CaravanInfoResponse.fromJson(Map<String, dynamic> json):
        list=convert(json);

  static List<CaravanQualificationResponse> convert(Map<String,dynamic> json) {
    var values = json['list'];
    if(values!=null) {
      return (values as List)
          .map((e) => e as Map<String,dynamic>)
          .map((e) => CaravanQualificationResponse.fromJson(e))
          .toList();

    }else{
      return List.empty();
    }
  }

}


class CaravanQualificationResponse{

  double score;
  int? qualificationSessionId;
  String setCode;

  CaravanQualificationResponse(this.score,this.qualificationSessionId,this.setCode);

  CaravanQualificationResponse.fromJson(Map<String, dynamic> json):
        score=json["score"],
        qualificationSessionId=json["qualificationSessionId"],
        setCode=json["setCode"];
}