class QualificationsResponse{



  final List<QualificationResponse> list;

  QualificationsResponse(this.list);

  QualificationsResponse.fromJson(Map<String, dynamic> json):
        list=convert(json);

  static List<QualificationResponse> convert(Map<String,dynamic> json) {
    var values = json['qualificationResponse'];
    if(values!=null) {
      return (values as List)
          .map((e) => e as Map<String,dynamic>)
          .map((e) => QualificationResponse.fromJson(e))
          .toList();

    }else{
      return List.empty();
    }
  }

}


class QualificationResponse{


  int? id;

  QualificationResponse(this.id);

  QualificationResponse.fromJson(Map<String, dynamic> json):
        id=json["id"];

}