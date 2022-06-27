import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/services/appointment_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/services/assignment_service.dart';
import 'package:mercadosalud/ui/favourite/favourite_view_model.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';

class MyAppointmentsViewModel extends StreamViewModel<List<Assignment>> {
  final _assignmentService = locator<AssignmentService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _appointmentService = locator<AppointmentService>();
  final _logger = getLogger('MyAppointmentsViewModel');

  FavouriteViewModel favouritesModel = FavouriteViewModel();
  bool pastEvents = false;

  MyAppointmentsViewModel(bool pastEvents) {
    this.pastEvents = pastEvents;
    initialise();
    setOnModelReadyCalled(true);
  }

  @override
  Stream<List<Assignment>> get stream =>
      _assignmentService.getMyAppointments(this, this.pastEvents);

  Future<bool> startCancellingAppointment(Assignment assignment) async {
    if (!isAppointmentDue(assignment)) {
      var r = await _bottomSheetService.showBottomSheet(
          title: LocaleKeys.UI_MyAppointmentsView_cancelacion_turno.tr(),
          description: LocaleKeys.UI_MyAppointmentsView_va_a_cancelar.tr(),
          confirmButtonTitle: LocaleKeys.UI_Shared_yes.tr(),
          cancelButtonTitle: LocaleKeys.UI_Shared_no.tr());
      var _confirmationResult = r?.confirmed;
      if (_confirmationResult!) {
        notifySourceChanged(clearOldData: true);
        return await _appointmentService.cancelAppointmentReservation(
            assignment);
      }
    }
    return false;
  }

  isAppointmentDue(Assignment assignment) {
    DateTime focused = assignment.fecha_turno!.toDate();
    DateTime now = DateTime.now();
    return (new DateTime(focused.year, focused.month, focused.day, focused.hour, focused.minute))
        .compareTo(new DateTime(now.year, now.month, now.day, now.hour, now.minute)) <
        0;
  }

}
