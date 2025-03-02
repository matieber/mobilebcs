
class ViewerCaravanScoreMessage{

    final int position;
    final double score;
    final String setCode;
    final String identification;


    ViewerCaravanScoreMessage(this.position,this.score,this.setCode,this.identification);

    ViewerCaravanScoreMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],score=json['score'],setCode=json['setCode'],identification=json['identification'];


    @override
    String toString() {
      return "($position,$score,$setCode,$identification)";
    }


}