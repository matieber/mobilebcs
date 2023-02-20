enum UserType{
  qualifier,
  viewer
}


extension UserTypeExtension on UserType {

  String get value {
    switch (this) {
      case UserType.qualifier:
        return 'Calificador';
      case UserType.viewer:
        return 'Observador';
    }
  }

}

