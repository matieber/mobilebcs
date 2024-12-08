import 'dart:typed_data';
import 'dart:convert';

class ViewerCaravanMessage{

    final int position;
    final List<Uint8List> byteImages;
    final String predictor;
    final String setCode;
    final String identification;
    final DateTime startTimeUTC;

  ViewerCaravanMessage(this.startTimeUTC,this.position,this.identification,this.byteImages,this.predictor,this.setCode);

  ViewerCaravanMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],
          predictor = json['predictor'],
          identification=json['identification'],
          setCode = json['setCode'],
          startTimeUTC= DateTime.parse(json['startTime']).toUtc(),
          byteImages=convert(json);

    @override
    String toString() {
      return "($position,$predictor,$byteImages,$setCode)";
    }

  static List<Uint8List> convert(Map<String,dynamic> json) {
    var image = json['images'];
    if(image!=null) {
      List<String> base64Images = (image as List)
          .map((e) => e as String)
          .toList();
      return base64Images.map((base64Image) {
        return base64Decode(base64Image);
      }).toList();
    }else{
      return List.empty();
    }
  }
}