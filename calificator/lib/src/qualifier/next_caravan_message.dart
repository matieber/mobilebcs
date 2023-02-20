class CaravanMessage{

    final int position;
    final String? setId;
    final String? locationCode;

  CaravanMessage(this.position, this.setId, this.locationCode);

  CaravanMessage.fromJson(Map<String,dynamic> json):
          position = json['position'],
          setId = json['setId'],
          locationCode =  json['locationCode'];

    @override
    String toString() {
      return "($position)";
    }
}