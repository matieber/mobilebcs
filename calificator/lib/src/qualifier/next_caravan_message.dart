import 'dart:typed_data';
import 'dart:convert';

class CaravanMessage{

    final int position;
    final String identification;
    final String? setCode;
    final String? locationCode;
    final List<Uint8List> byteImages;

  CaravanMessage(this.position, this.identification, this.setCode, this.locationCode,this.byteImages);

  CaravanMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],
          identification = json['identification'],
          setCode = json['setCode'],
          locationCode =  json['locationCode'],
          byteImages = convert(json);

    @override
    String toString() {
      return "($position)";
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