import 'package:calificator/src/diagram/prediction_response.dart';

class DiagramResponse{

  final List<PredictionResponse> values;

  DiagramResponse(this.values);

  DiagramResponse.fromJson(Map<String,dynamic> json):
        values = convert(json);

        static List<PredictionResponse> convert(Map<String,dynamic> json) {
    var values = json['values'];
    if(values!=null) {
     return (values as List)
          .map((e) => e as Map<String,dynamic>)
          .map((e) => PredictionResponse.fromJson(e))
          .toList();

    }else{
      return List.empty();
    }
  }
}