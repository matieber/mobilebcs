import 'dart:async';

import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/services/doctor_service.dart';
import 'package:mercadosalud/ui/home/posts/appointment_wrapper.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/ui/home/todo/dropdown_classes.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:flamingo/flamingo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class CalendarTemplateViewModel extends BaseViewModel {
  Hour? _selectedHourStart = null;
  Hour? _selectedHourEnd = null;
  Room? _selectedRoom = null;
  DateTime? _selectedDay = null;
  int _selectedPrice = 0;
  List<AppointmentWrapper>? selectedEvents = null;

  bool addShowContainer = false;

  final _bottomSheetService = locator<BottomSheetService>();
  final _firebaseAuthenticationService = locator<AuthenticationService>();
  final _doctorService = locator<DoctorService>();

  int appointmentDuration = 30;
  late List<Hour> start_hours;
  late List<Hour> end_hours_template;
  List<Room> rooms = <Room>[Room('Consultorio 1'), Room('Consultorio 2')];

  DateTime? loginClickTime;

  bool isRedundantClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime!).inSeconds}');
    if (currentTime.difference(loginClickTime!).inSeconds < 1) {
      //set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  CalendarTemplateViewModel() {
    //final doctor = locator<DoctorService>().currentDoctor;
    final doctor = null;
    if (doctor != null) {
      appointmentDuration = doctor.duracion_turno!;
    }
    start_hours = <Hour>[
      Hour('8:00'),
      Hour('9:00'),
      Hour('10:00'),
      Hour('11:00'),
      Hour('12:00'),
      Hour('13:00'),
      Hour('14:00'),
      Hour('15:00'),
      Hour('16:00'),
      Hour('17:00'),
      Hour('18:00'),
      Hour('19:00'),
    ];
    end_hours_template = <Hour>[
      Hour('9:00'),
      Hour('10:00'),
      Hour('11:00'),
      Hour('12:00'),
      Hour('13:00'),
      Hour('14:00'),
      Hour('15:00'),
      Hour('16:00'),
      Hour('17:00'),
      Hour('18:00'),
      Hour('19:00'),
      Hour('20:00'),
    ];
    initializeEvents();
  }

  Future initializeEvents() async {
    String currentUserId = _firebaseAuthenticationService.currentUser!.id;
    List<Appointment>? list =
        await _doctorService.getAppointments(currentUserId);
    if (list != null) {
      list.forEach((element) {
        String id = element.turno_id!;
        // id es "weekday_hora_fraccion"
        int itemWeekday = int.parse(id.split("_")[0]);
        addItemToDay(element, itemWeekday);
      });
      events.forEach((weekdayList) {
        weekdayList!.sort((e1, e2) => e1.compareTo(e2));
      });
    }
    notifyListeners();
  }

  final events =
      List<List<AppointmentWrapper>?>.filled(7, null, growable: false);

  Future<List<AppointmentWrapper>> getEventsForDay(DateTime day) async {
    initializeEntry(day.weekday);
    return events[day.weekday - 1]!;
  }

  void initializeEntry(int weekday) {
    int arrayIndex = weekday - 1;
    if (events[arrayIndex] == null) {
      events[arrayIndex] = List<AppointmentWrapper>.empty(growable: true);
    }
  }

  void addItemToDay(Appointment app, int itemWeekday) {
    initializeEntry(itemWeekday);
    events[itemWeekday - 1]!.add(AppointmentWrapper(wrapped: app));
  }

  Hour getSelectedHourStart() {
    return _selectedHourStart ?? start_hours.first;
  }

  void setSelectedHourStart(Hour? newValue) {
    _selectedHourStart = newValue!;
    _selectedHourEnd = null;
    notifyListeners();
  }

  List<Hour> getEndHours() {
    List<Hour> end_hours = List<Hour>.empty(growable: true);
    end_hours_template.forEach((element) {
      if (Hour.index(element.hour) > Hour.index(getSelectedHourStart().hour)) {
        end_hours.add(element);
      }
    });
    return end_hours;
  }

  Hour getSelectedHourEnd() {
    return _selectedHourEnd ?? getEndHours().first;
  }

  void setSelectedHourEnd(Hour? newValue) {
    _selectedHourEnd = newValue!;
    notifyListeners();
  }

  Room getSelectedRoom() {
    return _selectedRoom ?? rooms.first;
  }

  void setSelectedRoom(Room? newValue) {
    _selectedRoom = newValue!;
    notifyListeners();
  }

  int getSelectedPrice() {
    return _selectedPrice;
  }

  void setSelectedPrice(int price) {
    _selectedPrice = price;
    //notifyListeners();
  }

  DateTime getFocusedDay() {
    if (_selectedDay == null) {
      _selectedDay = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
    }
    return _selectedDay!;
  }

  void setFocusedDay(DateTime selectedDay) {
    //if (!isSameDay(selectedDay, _selectedDay)) {
    _selectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    updateTodaysEventlist();
    notifyListeners();
    //}
  }

  void cancelAddingEvent() {
    _selectedHourStart = null;
    _selectedHourEnd = null;
    _selectedRoom = null;
    _selectedPrice = 0;
    this.addShowContainer = false;
    updateTodaysEventlist();
    notifyListeners();
  }

  void startAddingEvent() {
    this.addShowContainer = true;
    notifyListeners();
  }

  Future<void> saveEvent() async {
    //this.setBusy(true);
    //notifyListeners();
    await runBusyFuture(_saveEvent());
  }

  Future<void> _saveEvent() async {
    if (getSelectedPrice() == 0) {
      _bottomSheetService.showBottomSheet(
          title: LocaleKeys.UI_CalendarView_error.tr(),
          description: "Por favor, establezca un precio");
      return;
    }
    List<AppointmentWrapper> items =
        await this.getEventsForDay(this.getFocusedDay());
    String currentUserId = _firebaseAuthenticationService.currentUser!.id;

    int index_start = Hour.index(getSelectedHourStart().hour);
    int index_end = Hour.index(getSelectedHourEnd().hour);
    bool overlap = false;
    while (index_start < index_end) {
      int current_fraction = 0;
      while (current_fraction < 60 / appointmentDuration) {
        String template_appointment_id = getFocusedDay().weekday.toString() +
            "_" +
            start_hours.elementAt(index_start).hour +
            "_" +
            current_fraction.toString();
        Appointment appointment = new Appointment(
            turno_id: template_appointment_id,
            medico_id: currentUserId,
            fecha: Timestamp.fromDate(getFocusedDay()),
            duracion: this.appointmentDuration,
            hora_inicio: start_hours.elementAt(index_start).hour,
            libre: true,
            precio: getSelectedPrice());
        AppointmentWrapper wrapper = AppointmentWrapper(wrapped: appointment);
        if (items.contains(wrapper)) {
          overlap = true;
        } else {
          items.add(wrapper);
        }
        current_fraction++;
      }
      index_start++;
    }
    if (overlap) {
      String errorIfAlreadyExists =
          LocaleKeys.UI_CalendarView_element_exists.tr();
      _bottomSheetService.showBottomSheet(
          title: LocaleKeys.UI_CalendarView_error.tr(),
          description: errorIfAlreadyExists);
    }
    items.sort((e1, e2) => e1.compareTo(e2));
    updateTodaysEventlist();
    this.addShowContainer = false;
    notifyListeners();
  }

  Future<void> updateTodaysEventlist() async {
    this.selectedEvents = await this.getEventsForDay(this._selectedDay!);
  }

  List<AppointmentWrapper> getSelectedEvents() {
    return this.selectedEvents ?? [];
  }

  void startEditingEvent(int index) {
    _bottomSheetService.showBottomSheet(
        title: LocaleKeys.UI_CalendarView_error.tr(),
        description: LocaleKeys.UI_CalendarView_edicion_faltante.tr());
  }

  Future<void> removeFromSelectedEvents(int index) async {
    this.getSelectedEvents().removeAt(index);
    this.notifyListeners();
  }

  Future<void> persistTemplate() async {
    await runBusyFuture(_persistTemplate());
  }

  Future<void> _persistTemplate() async {
    int total = 0;
    this.events.forEach((element) {
      total += element!.length;
    });
    if (total == 0) {
      _bottomSheetService.showBottomSheet(
          title: LocaleKeys.UI_CalendarView_error.tr(),
          description: LocaleKeys.UI_CalendarTemplateView_template_vacio.tr());
      return;
    }
    List<Appointment> toPersist = List<Appointment>.empty(growable: true);
    events.forEach((outerList) {
      outerList!.forEach((wrapper) {
        toPersist.add(wrapper.wrapped);
      });
    });
    String currentUserId = _firebaseAuthenticationService.currentUser!.id;
    saveAppointments(currentUserId, toPersist);
  }

  void saveAppointments(String medico_id, List<Appointment> list) async {
    Future<bool> delResponse = _doctorService.deleteAppointments(medico_id);
    delResponse.then((valueDel) {
      if (valueDel) {
        print("Remove result? = " + valueDel.toString());
        Future<bool> saveResponse =
            _doctorService.saveAppointments(medico_id, list);
        saveResponse.then((valueSave) {
          if (!valueSave) {
            showConnectionError();
          } else {
            showSaveSuccessful();
          }
        });
      } else {
        showConnectionError();
      }
    });
  }

  void showConnectionError() {
    _bottomSheetService.showBottomSheet(
        title: LocaleKeys.UI_CalendarView_error.tr(),
        description: LocaleKeys.UI_CalendarView_errorGralConexion.tr());
  }

  void showSaveSuccessful() {
    _bottomSheetService.showBottomSheet(
        title: LocaleKeys.UI_CalendarView_info.tr(),
        description: LocaleKeys.UI_CalendarTemplateView_templateSavedOk.tr());
  }
}
