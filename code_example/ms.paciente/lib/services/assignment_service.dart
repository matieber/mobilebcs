import 'package:flamingo/flamingo.dart';
import 'package:flutter/services.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/ui/home/appointment/my_appointments_viewmodel.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

class AssignmentService {
  final _userService = locator<UserService>();

  final _logger = getLogger('AssignmentService');

  Future<Assignment?> createAssignment(Appointment turno, Doctor doctor,
      PersonaACargo paciente, int price) async {
    try {
      final documentAccessor = DocumentAccessor();
      Assignment assignment = Assignment(
          id: turno.id,
          precio: price,
          medico_id: turno.medico_id,
          turno_id: turno.id,
          paciente_fullName: paciente.fullName,
          paciente_sexo: _userService.currentUser!.sex,
          paciente_dni: paciente.dni,
          //hora_inicio: turno.hora_inicio,
          hora_inicio: turno.hora_min_inicio,
          paciente_email: _userService.currentUser!.email,
          doctor_email: doctor.email,
          doctor_dni: doctor.dni,
          doctor_fullName: doctor.fullName,
          fecha_turno: turno.fecha,
          paciente_id: _userService.currentUser!.id,
          fecha_reserva: Timestamp.now());
      return await documentAccessor.save(assignment);
    } catch (e) {
      logError(e);
      return null;
    }
  }

  Stream<List<Assignment>> getMyAppointments(
      MyAppointmentsViewModel myAppointmentsViewModel,
      bool pastAppointments) async* {
    try {
      final path = Document.path<Assignment>();
      DateTime now = DateTime.now();
      DateTime todayEarlyMorning =
          DateTime(now.year, now.month, now.day, 7, 0, 0);
      Timestamp ts = Timestamp.fromDate(todayEarlyMorning);

      Stream<QuerySnapshot<Map<String, dynamic>>>? snapshots = null;
      var partialQuery = firestoreInstance
          .collection(path)
          .where("paciente_id", isEqualTo: _userService.currentUser!.id);
      if (pastAppointments) {
        snapshots =
            partialQuery.where("fecha_turno", isLessThan: ts).get().asStream();
      } else {
        snapshots = partialQuery
            .where("fecha_turno", isGreaterThan: ts)
            .orderBy("fecha_turno", descending: true)
            .get()
            .asStream();
      }

      await for (final snapshot in snapshots) {
        final events = snapshot.docs
            .map((document) => Assignment(snapshot: document))
            .toList();
        events.sort((a1,a2) => a1.compareTo(a2));
        print("Asignaciones de turnos $events");
        yield events;
      }
    } catch (e) {
      _logger.d("${_userService.currentUser!.id} mis turnos exception!!! ");
      logError(e);
    }
  }

  void logError(Object e) {
    String? errorMsg;
    if (e is PlatformException) {
      errorMsg = e.message;
    } else if (e is Exception) {
      errorMsg = e.toString();
    }
    print(errorMsg);
    _logger.e(errorMsg);
  }

  Future<bool> removeAssignment(Assignment assignment) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.delete(Assignment(id: assignment.id));
      return true;
    } catch (e) {
      logError(e);
      return false;
    }
  }
}
