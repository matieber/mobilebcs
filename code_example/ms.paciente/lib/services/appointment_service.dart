import 'dart:async';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:flutter/services.dart';

import 'package:mercadosalud/app/app.logger.dart';

import 'package:flamingo/flamingo.dart';
import 'package:stacked_services/stacked_services.dart';

import 'assignment_service.dart';

class AppointmentService {

  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _assignmentService = locator<AssignmentService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _logger = getLogger('AppointmentService');

  Future<String?> createAppointment(Appointment turno) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.save(turno);
      return turno.id;
    } catch (e) {
      logError(e);
      return null;
    }
  }

  Future<Appointment?> getAppointment(String turno_id) async {
    try {
      final documentAccessor = DocumentAccessor();
      var turnoData =
          await documentAccessor.load<Appointment>(Appointment(id: turno_id));
      return turnoData;
    } catch (e) {
      logError(e);
      return null;
    }
  }

  Future<bool> deleteAppointment(String turno_id) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.delete(Appointment(id: turno_id));

      return true;
    } catch (e) {
      logError(e);
      return false;
    }
  }

  Future updateAppointment(Appointment turno) async {
    try {
      final documentAccessor = DocumentAccessor();
      await documentAccessor.update(turno);
    } catch (e) {
      logError(e);
      return null;
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

  Future<List<Appointment>?> getAppointments(
      String medico_id, DateTime date) async {
    try {
      final path = Document.path<Appointment>();
      _logger.d("$medico_id $date");
      var snapshot = await firestoreInstance
          .collection(path)
          .where("medico_id", isEqualTo: medico_id)
          .where("fecha", isEqualTo: date)
          .where("libre", isEqualTo: true)
          .get();

      final listA =
          snapshot.docs.map((item) => Appointment(snapshot: item)).toList()
            ..forEach((app) {
              print(app.id); // user model.
            });

      _logger.d("$medico_id $date turnos: $listA");
      return listA;
      //}
    } catch (e) {
      _logger.d("$medico_id $date turnos exception!!! ");
      logError(e);
      return null;
    }
  }

  Future<List<Appointment>> getAppointmentsForDateRange(
      String medico_id, DateTime initDate, DateTime endDate, int limit) async {
    try {
      final path = Document.path<Appointment>();
      _logger
          .d("Looking for appointments: $medico_id from $initDate to $endDate");
      var snapshot = await firestoreInstance
          .collection(path)
          .where("medico_id", isEqualTo: medico_id)
          .where("fecha", isGreaterThanOrEqualTo: initDate)
          .where("fecha", isLessThanOrEqualTo: endDate)
          .where("libre", isEqualTo: true)
          .orderBy("fecha", descending: false)
          .limit(limit)
          .get();

      final list =
          snapshot.docs.map((item) => Appointment(snapshot: item)).toList()
            ..forEach((app) {
              print(app.fecha); // user model.
            });

      return list;
      //}
    } catch (e) {
      _logger.d("$medico_id range $initDate $endDate turnos exception!!! ");
      logError(e);
      return [];
    }
  }

  void reserveAppointment(Appointment appointment, Doctor doctor,
      PersonaACargo paciente, int price) async {
    _logger.d("AppointmentID: ${appointment.id} $price");
    try {
      RunTransaction.scope((transaction) async {
        DocumentAccessor documentAccessor = DocumentAccessor();
        await documentAccessor.load<Appointment>(appointment,
            source: Source.server);

        if (appointment.libre == true) {
          appointment.libre = false;
          transaction.update(appointment.reference, appointment.toData());
          _assignmentService.createAssignment(
              appointment, doctor, paciente, price);

          var r = await _bottomSheetService.showBottomSheet(
              title: "Información",
              description: "Turno reservado exitosamente");
          if (r!.confirmed){
            _navigationService.clearStackAndShow(Routes.homeView,
                arguments: HomeViewArguments(focusedTab: 1));
          }
        } else {
          _bottomSheetService.showBottomSheet(
              title: "Error",
              description: "Lo sentimos, el ya turno ha sido tomado");
          _logger.d("Lo sentimos, el ya turno ha sido tomado");
        }
      });
    } catch (e) {
      logError(e);
    }
  }

  Future<bool> cancelAppointmentReservation(Assignment assignment) async {
      _logger.d("Cancelling reservation. AppointmentID: ${assignment.id}");
      bool op = false;
      try {
        RunTransaction.scope((transaction) async {

          bool r = await _assignmentService.removeAssignment(assignment);
          if (r == true) {
            DocumentAccessor documentAccessor = DocumentAccessor();
            Appointment? appointment = await documentAccessor.load<Appointment>(
                Appointment(id: assignment.id), source: Source.server);
            if (appointment != null) {
              appointment.libre = true;
              transaction.update(appointment.reference, appointment.toData());
              _bottomSheetService.showBottomSheet(
                  title: "Información",
                  description: "Turno cancelado exitosamente");
              op = true;
            } else {
              _bottomSheetService.showBottomSheet(
                  title: "Error",
                  description: "Error al intentar cancelar turno");
              _logger.d("Error al intentar cancelar turno");
            }
          }
        });
        return op;
      } catch (e) {
        logError(e);
        return op;
      }
  }
}
