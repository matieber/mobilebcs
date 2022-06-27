class Hour{
  // Hora de comienzo de turnos
  static int startingHour = 8;
  String hour;
  Hour(this.hour);

  static int index(String hourValue) {
    return int.parse(hourValue.split(":")[0]) - startingHour;
  }

  int getIndex() {
    return Hour.index(this.hour);
  }
}
class Fraction{
  late String fraction;
  late int start_minute;
  late int my_index;

  static List<String> ordinal = <String>[
    "Primeros",
    "Segundos",
    "Terceros",
    "Cuartos",
    "Quintos",
    "Sextos"
  ];

  Fraction(int index, int appointmentDuration) {
    this.my_index = index - 1;
    this.start_minute = (my_index*appointmentDuration);
    this.fraction = ordinal[index-1] + " " + appointmentDuration.toString() + " minutos";
  }

  static int index(String fractionValue) {
    return ordinal.indexOf(fractionValue.split(" ")[0]);
  }
  int getIndex() {
    return this.my_index - 1;
  }
}
class Room{
  String room;
  Room(this.room);
}
class EventStore {
  String hour;
  String fraction;
  String room;
  bool free;
  int? duration;
  late String firebaseId;
  late int price;

  EventStore({required this.hour, required this.fraction, required this.free, required this.room, this.duration});

  int compareTo(EventStore e2) {
    // this < e2 -> retornar -1
    // this > e2 -> retornar 1
    // this == e2 -> retornar 0
    if (Hour.index(this.hour) < Hour.index(e2.hour)) {
      return -1;
    }
    if (Hour.index(this.hour) > Hour.index(e2.hour)) {
      return 1;
    }
    if (Hour.index(this.hour) == Hour.index(e2.hour)) {
      if (Fraction.index(this.fraction) < Fraction.index(e2.fraction)) {
        return -1;
      }
      if (Fraction.index(this.fraction) > Fraction.index(e2.fraction)) {
        return 1;
      }
    }
    return 0;
  }

  @override
  bool operator ==(Object other) => other is EventStore && this.compareTo(other) == 0;

  @override
  int get hashCode => (this.hour + this.fraction).hashCode;
}