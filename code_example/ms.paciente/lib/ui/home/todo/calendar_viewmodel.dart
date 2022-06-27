import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/services/price_service.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:mercadosalud/ui/home/todo/family_members_viewmodel.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:mercadosalud/services/appointment_service.dart';
import 'package:mercadosalud/services/doctor_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/table_calendar/table_calendar.dart';
import 'dropdown_classes.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:easy_localization/easy_localization.dart';

class CalendarViewModel extends BaseViewModel {
  Hour? _selectedHour = null;
  Fraction? _selectedFraction = null;
  Room? _selectedRoom = null;
  late String doctorId;
  late Doctor doctor;

  DateTime? _selectedDay = null;
  bool _isFocusedDayDue = false;
  List<EventStore>? selectedEvents = null;
  final _logger = getLogger('CalendarViewModel');
  Map<String, Appointment> selectedAppointments = Map<String, Appointment>();
  Appointment? selectedAppointment;

  final _bottomSheetService = locator<BottomSheetService>();
  final _appointmentService = locator<AppointmentService>();
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final _navigationService = locator<NavigationService>();
  final _priceService = locator<PriceService>();

  List<Room> rooms = <Room>[Room('Consultorio 1'), Room('Consultorio 2')];

  CalendarViewModel(Doctor doctor) {
    this.doctorId = doctor.id;
    this.doctor = doctor;
    print("CalendarViewModel of Doctor ID: " + doctorId);
  }

  final events = LinkedHashMap<DateTime, List<EventStore>>(equals: isSameDay);

  get selectedFamilyMember => null;

  Future<List<EventStore>> getEventsForDay(DateTime day) async {
    DateTime noTimeDate = new DateTime(day.year, day.month, day.day);

    if (events[noTimeDate] == null) {
      DateTime now = DateTime.now();
      DateTime todayEarlyMorning =
          DateTime(now.year, now.month, now.day, 7, 0, 0);
      // No tiene sentido mostrar los turnos pasados
      if (noTimeDate.isBefore(todayEarlyMorning)) {
        events[noTimeDate] = List<EventStore>.empty(growable: false);
      } else {
        events[noTimeDate] = List<EventStore>.empty(growable: true);
        final appointments = await _appointmentService.getAppointments(
            this.doctorId, noTimeDate);

        if (appointments != null) {
          appointments.forEach((element) {
            String storedFraction = element.turno_id!.split("_").last;
            _logger.d("Element: ${element.id}");
            selectedAppointments[element.id] = element;
            Fraction f =
                Fraction(int.parse(storedFraction) + 1, element.duracion!);
            EventStore evt = new EventStore(
                hour: element.hora_inicio!,
                fraction: f.fraction,
                free: element.libre!,
                room: rooms.first.room,
                duration: element.duracion);
            evt.firebaseId = element.id;
            evt.price = element.precio!;
            events[noTimeDate]!.add(evt);
            events[noTimeDate]!.sort((e1, e2) => e1.compareTo(e2));
          });
        }
      }
    }
    return events[noTimeDate]!;
  }

  DateTime getFocusedDay() {
    if (_selectedDay == null) {
      _selectedDay = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
    }
    return _selectedDay!;
  }

  bool isFocusedDayDue() {
    DateTime focused = this.getFocusedDay();
    DateTime now = DateTime.now();
    return (new DateTime(focused.year, focused.month, focused.day))
            .compareTo(new DateTime(now.year, now.month, now.day)) <
        0;
  }

  void setFocusedDay(DateTime selectedDay) {
    _selectedDay =
        new DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    _isFocusedDayDue = isFocusedDayDue();
    updateTodaysEventlist();
    notifyListeners();
  }

  Future<void> updateTodaysEventlist() async {
    this.selectedEvents = await this.getEventsForDay(this._selectedDay!);
  }

  List<EventStore> getSelectedEvents() {
    return this.selectedEvents ?? [];
  }

  int getPriceForEvent(EventStore evt) {
    // El precio para el evento no se estableció originalmente mediante precio dinámico,
    // por lo tanto se muestra el precio elegido
    if (evt.price > 0) return evt.price;
    int weekday = getFocusedDay().weekday;
    int start_hour = int.parse(evt.hour.split(":")[0]);
    return _priceService
        .getPrice(this.doctor.especialidad ?? "", weekday, start_hour,
            this.doctor.address!.comuna ?? "", this.doctor.address!.city ?? "")
        .toInt();
  }

  Appointment getAppointmentDetails(int index) {
    Appointment a =
        selectedAppointments[selectedEvents!.elementAt(index).firebaseId]!;
    a.precio = getPrice(index);
    return a;
  }

  int getPrice(int index) {
    return getPriceForEvent(selectedEvents!.elementAt(index));
  }

  void appointmentReservationEvent(PersonaACargo paciente, int price) async {
    _logger.d("Reserva: $price");

    if (selectedAppointment != null) {
      _appointmentService.reserveAppointment(
          selectedAppointment!, doctor, paciente, price);
      selectedAppointments.remove(selectedAppointment!.id);
    }
  }

  navigateToMyAppointments() {
    /*_navigationService.clearStackAndShow(Routes.homeView,
        arguments: HomeViewArguments(focusedTab: 0));*/
  }
}
