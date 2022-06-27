import 'package:mercadosalud/ui/home/todo/dropdown_classes.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

class AppointmentWrapper {
  Appointment wrapped;

  AppointmentWrapper({required this.wrapped});

  int compareTo(AppointmentWrapper e2) {
    // this < e2 -> retornar -1
    // this > e2 -> retornar 1
    // this == e2 -> retornar 0
    if (Hour.index(wrapped.hora_inicio!) <
        Hour.index(e2.wrapped.hora_inicio!)) {
      return -1;
    }
    if (Hour.index(wrapped.hora_inicio!) >
        Hour.index(e2.wrapped.hora_inicio!)) {
      return 1;
    }
    if (Hour.index(wrapped.hora_inicio!) ==
        Hour.index(e2.wrapped.hora_inicio!)) {
      if (int.parse(getFractionId()) <
          int.parse(fractionId(e2.wrapped.turno_id!))) {
        return -1;
      }
      if (int.parse(getFractionId()) >
          int.parse(fractionId(e2.wrapped.turno_id!))) {
        return 1;
      }
    }
    return 0;
  }

  String fractionId(String _turno_id) {
    return _turno_id.split("_").last;
  }

  String getFractionId() {
    return fractionId(this.wrapped.turno_id!);
  }

  @override
  bool operator ==(Object other) =>
      other is AppointmentWrapper && this.compareTo(other) == 0;

  @override
  int get hashCode =>
      (this.wrapped.hora_inicio! + this.wrapped.turno_id!.split("_").last)
          .hashCode;
}
