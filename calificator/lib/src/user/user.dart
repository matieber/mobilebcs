import 'package:calificator/src/user/user_type.dart';

class User{

  String username;

  UserType userType;

  int? qualificationSession;

  User(this.username,this.userType,this.qualificationSession);

  factory User.fromJson(dynamic json){
    String stringUserType = json['userType'];
    UserType userType=UserType.values.byName(stringUserType.toLowerCase());
    return User(json['username'], userType,json['qualificationSession']);
  }
}