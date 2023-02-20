import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/widgets.dart';

class ViewerCaravanMessage{

    final int position;
    final List<Uint8List> byteImages;

  ViewerCaravanMessage(this.position,this.byteImages);

  ViewerCaravanMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],
          byteImages=convert(json);

    @override
    String toString() {
      return "($position,$byteImages)";
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