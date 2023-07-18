import 'dart:typed_data';
import 'dart:convert';

class ViewerCaravanScoreMessage{

    final int position;
    final double score;
    final String setCode;


    ViewerCaravanScoreMessage(this.position,this.score,this.setCode);

    ViewerCaravanScoreMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],score=json['score'],setCode=json['setCode'];


    @override
    String toString() {
      return "($position,$score,$setCode)";
    }


}