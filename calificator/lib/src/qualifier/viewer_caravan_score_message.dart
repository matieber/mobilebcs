import 'dart:typed_data';
import 'dart:convert';

class ViewerCaravanScoreMessage{

    final int position;
    final double score;


    ViewerCaravanScoreMessage(this.position,this.score);

    ViewerCaravanScoreMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],score=json['score'];


    @override
    String toString() {
      return "($position,$score)";
    }


}