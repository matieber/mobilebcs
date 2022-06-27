import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'family_members_viewmodel.dart';
import 'time_and_duration.dart';
import 'dropdown_classes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mercadosalud/table_calendar/table_calendar.dart';
import 'calendar_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/scheduler.dart';

class CalendarView extends StatelessWidget {
  CalendarView(
      {Key? key, Doctor? doctor, SearchFormViewModel? searchCriteria}) {
    this.doctorId = doctor!.id;
    this.doctor = doctor;
    this.searchCriteria = searchCriteria!;
  }

  late String doctorId;
  late Doctor doctor;
  late SearchFormViewModel searchCriteria;
  DateTime? loginClickTime;
  final _logger = getLogger('CalendarView');

  final _userService = locator<UserService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();

  final _nagivationService = locator<NavigationService>();

  bool isRedundantClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CalendarViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Turnos disponibles"),
        ),
        body: model.isBusy ? buildProgress() : buildMainWidget(model, context),
      ),
      viewModelBuilder: () => CalendarViewModel(this.doctor),
    );
  }

  Widget buildProgress() {
    return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.black)));
  }

  Widget buildMainWidget(CalendarViewModel model, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(Icons.person, size: 70.0, color: Colors.blueAccent),
          Container(
            alignment: Alignment.centerLeft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    doctor.titulo_cortesia! + " " + doctor.fullNameCap!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${doctor.especialidad!}',
                    style: TextStyle(fontSize: 15, fontFamily: 'EBGaramond'),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Matricula:${doctor.matricula}',
                    style: TextStyle(fontSize: 15, fontFamily: 'EBGaramond'),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    '${doctor.address!.street} ${doctor.address!.number},'
                    '${doctor.address!.cityCap}',
                    style: TextStyle(fontSize: 15, fontFamily: 'EBGaramond'),
                  ),
                  SizedBox(
                    height: 10,
                    width: 150,
                    child: Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28))),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(child: buildTableCalendar(model)),
                  verticalSpaceSmall,
                  ...model.getSelectedEvents().map((EventStore) {
                    int index = model.getSelectedEvents().indexOf(EventStore);
                    bool addDivider = checkAddDivider(model, index, EventStore);

                    return GestureDetector(
                      onTap: () {
                        if (!model.isFocusedDayDue())
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              model.selectedAppointment =
                                  model.getAppointmentDetails(index);
                              return _showAppointmentPreReservationDetails(
                                  model, index);
                            },
                          );
                      },
                      child: drawEvent(EventStore, addDivider, model),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showAppointmentPreReservationDetails(CalendarViewModel model, int index) {
    return Dialog(
        child: ViewModelBuilder<FamilyMembersViewModel>.reactive(
            onModelReady: (model) =>
                SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
                  model.runStartUpLogic();
                }),
            builder: (context, familymodel, child) =>
                StatefulBuilder(// You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
                  familymodel.familySelectorState = setState;
                  print(
                      "Initialized family member: ${familymodel.selectedFamilyMember?.fullName}");
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.50,
                    //width: MediaQuery.of(context).size.width * 0.90,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(children: [
                        Container(
                          height: 5,
                        ),
                        Text(
                          "Reserva de turno",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: 10,
                        ),
                        Expanded(
                          child:
                              buildFamilyMemberSelector(familymodel, context),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(children: [
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 0.0),
                                  child: Icon(Icons.calendar_today_rounded)),
                              Text(
                                "${model.selectedAppointment!.fecha!.toDate().day}-"
                                "${model.selectedAppointment!.fecha!.toDate().month}-"
                                "${model.selectedAppointment!.fecha!.toDate().year}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 0.0),
                                  child: Icon(Icons.schedule)),
                              Text(
                                "${model.selectedAppointment!.hora_min_inicio} hs.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ]),
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 0.0,
                                      right: 5.0,
                                      bottom: 0.0),
                                  child: Icon(Icons.attach_money)),
                              Text(
                                "${model.selectedAppointment!.precio}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ])
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(children: [
                            ElevatedButton(
                                child: Text("Reservar"),
                                onPressed: () {
                                  final enabled_user = _userService.isEnabled;
                                  _logger.d("User enabled $enabled_user");
                                  if (!enabled_user) {
                                    _nagivationService
                                        .replaceWith(Routes.startUpView);
                                  }
                                  if (familymodel.selectedFamilyMember !=
                                          null &&
                                      enabled_user) {
                                    print(
                                        "appointment:${model.selectedAppointment!.id}, familymodel: ${familymodel.selectedFamilyMember!.fullName!}");
                                    model.appointmentReservationEvent(
                                        familymodel.selectedFamilyMember!,
                                        model.selectedAppointment!.precio!);
                                    Navigator.of(context).pop();
                                    model.navigateToMyAppointments();
                                  }
                                })
                          ]),
                        ),
                      ]),
                    ),
                  );
                }),
            viewModelBuilder: () => FamilyMembersViewModel()));
  }

  Widget buildFamilyMemberSelector(
      FamilyMembersViewModel model, BuildContext context) {
    final focus_node = FocusNode();

    return Container(
      color: Colors.transparent,
      child: new Column(
        children: <Widget>[
          //Container(height: 10,),
          Row(children: <Widget>[
            Container(
              height: 20,
            ),
            Text('El turno es para:',
                style: Theme.of(context).textTheme.subtitle1),
            const Padding(
              padding: EdgeInsets.only(bottom: 5.0),
            )
          ]),
          Focus(
              canRequestFocus: true,
              focusNode: focus_node, //This is the important part
              autofocus: true,
              child: FormBuilderChoiceChip(
                name: "appointmentFor",
                focusNode: focus_node,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                alignment: WrapAlignment.center,
                initialValue: model.selectedFamilyMember,
                onChanged: (PersonaACargo? newValue) {
                  model.selectedFamilyMember = newValue;
                },
                options: _buildFormBuilderChoices(model),
                visualDensity: VisualDensity.comfortable,
                spacing: 10,
                runSpacing: 10,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                ]),
              )),
        ],
      ),
    );
  }

  List<FormBuilderFieldOption<PersonaACargo>> _buildFormBuilderChoices(
      FamilyMembersViewModel model) {
    List<FormBuilderFieldOption<PersonaACargo>> choices = [];
    model.familyMembers.forEach((item) {
      choices.add(
        FormBuilderFieldOption(value: item, child: Text(item.fullName)),
      );
    });
    return choices;
  }

  // Se retorna el primer dia del presente mes
  DateTime _getFirstDay() {
    DateTime now = DateTime.now();
    return new DateTime(now.year, now.month, 1);
  }

  // Se retorna el dia actual
  DateTime _getFocusedDay(CalendarViewModel model) {
    return model.getFocusedDay();
  }

  // Se retorna el último dia del mes siguiente
  DateTime _getLastDay() {
    DateTime now = DateTime.now();
    int nextMonth = now.month + 1;
    int res_nextMonth = (nextMonth == 13) ? 1 : nextMonth;
    int res_nextYear = (nextMonth == 13) ? now.year + 1 : now.year;
    return new DateTime(res_nextYear, res_nextMonth,
        getDaysInMonth(res_nextYear, res_nextMonth));
  }

  int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    switch (month) {
      case 1:
        {
          return 31;
        }
      case 3:
        {
          return 31;
        }
      case 4:
        {
          return 30;
        }
      case 5:
        {
          return 31;
        }
      case 6:
        {
          return 30;
        }
      case 7:
        {
          return 31;
        }
      case 8:
        {
          return 31;
        }
      case 9:
        {
          return 30;
        }
      case 10:
        {
          return 31;
        }
      case 11:
        {
          return 30;
        }
      default:
        {
          return 31;
        }
    }
  }

  void _onDaySelected(
      DateTime selectedDay, DateTime focusedDay, CalendarViewModel model) {
    model.setFocusedDay(selectedDay);
  }

  Future<List<EventStore>> _loadEvents(
      DateTime day, CalendarViewModel model) async {
    return await model.getEventsForDay(day);
  }

  Widget buildTableCalendar(CalendarViewModel model) {
    return TableCalendar(
      selectedDayPredicate: (day) {
        return isSameDay(model.getFocusedDay(), day);
      },
      firstDay: _getFirstDay(),
      focusedDay: _getFocusedDay(model),
      lastDay: _getLastDay(),
      rowHeight: 45.0,
      daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) =>
              DateFormat.E(locale).format(date)[0],
          weekdayStyle: TextStyle(color: Colors.grey),
          weekendStyle: TextStyle(color: Colors.grey)),
      rangeSelectionMode: RangeSelectionMode.toggledOff,
      eventLoader: (day) async {
        return await _loadEvents(day, model);
      },
      calendarFormat: CalendarFormat.month,
      calendarStyle: CalendarStyle(
          outsideTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
          weekendTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
          canMarkersOverflow: true,
          todayTextStyle: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 18.0, color: Colors.white),
          selectedTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18.0,
              color: Colors.white)),
      headerStyle: HeaderStyle(
        headerMargin: EdgeInsets.only(bottom: 16),
        leftChevronIcon: Icon(
          Icons.calendar_today,
          color: Color(0xFF334192),
          size: 25,
        ),
        decoration: BoxDecoration(color: Color(0xFFF4F5F6)),
        titleTextStyle: TextStyle(fontSize: 25, fontFamily: "Poppins"),
        formatButtonVisible: false,
        //centerHeaderTitle: true,
        formatButtonDecoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20.0),
        ),
        formatButtonTextStyle: TextStyle(color: Colors.white),
        formatButtonShowsNext: false,
      ),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      onDaySelected: (selectedDay, focusedDay) {
        _onDaySelected(selectedDay, focusedDay, model);
      },
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, day, focusedDay) => Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(0xFF334192),
                borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              day.day.toString(),
              style: TextStyle(color: Colors.white),
            )),
        todayBuilder: (context, day, focusedDay) => Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.green, //Color(0xFF334192),
                borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              day.day.toString(),
              style: TextStyle(color: Colors.white),
            )),
        markerBuilder: (context, day, events) => buildMarker(events),
      ),
    );
  }

  Widget? buildMarker(List<Object?> objects) {
    _logger.d("Received objects: ${objects.length}");
    if ((objects == null) || (objects.length == 0)) {
      return null;
    }
    int totalFree = objects.length;

    return Text(totalFree.toString(), style: TextStyle(color: Colors.green));
  }

  bool checkAddDivider(
      CalendarViewModel model, int index, EventStore currentMappedEvent) {
    if (index == 0) return true;
    EventStore previousEvent = model.getSelectedEvents().elementAt(index - 1);
    if (currentMappedEvent.hour != previousEvent.hour) return true;
    return false;
  }

  Widget drawEvent(
      EventStore currentMappedEvent, bool addDivider, CalendarViewModel model) {
    var start_minute = Fraction.index(currentMappedEvent.fraction) *
        currentMappedEvent.duration!;
    Column col = Column(
      children: [
        TimeAndDuration(
          time: currentMappedEvent.hour.toString(),
          timeWithinHour: start_minute == 0 ? "00" : start_minute.toString(),
          free: currentMappedEvent.free,
          price: model.getPriceForEvent(currentMappedEvent),
        ),
      ],
    );
    if (addDivider) {
      return Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Column(
              children: <Widget>[Divider(color: Colors.black), col],
            ),
          )
        ],
      );
    }
    return col;
  }
}
