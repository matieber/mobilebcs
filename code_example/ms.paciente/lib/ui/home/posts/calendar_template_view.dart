import 'package:flutter/services.dart';
import 'package:mercadosalud/ui/home/posts/appointment_wrapper.dart';
import 'package:mercadosalud/ui/home/posts/time_and_duration_template.dart';
import 'package:mercadosalud/ui/home/todo/dropdown_classes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mercadosalud/table_calendar/table_calendar.dart';
import 'calendar_template_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:mercadosalud/ui/shared/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class CalendarTemplateView extends StatelessWidget {
  CalendarTemplateView({Key? key}) : super(key: key);

  DateTime? loginClickTime;

  bool isRedundentClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime!).inSeconds}');
    if (currentTime.difference(loginClickTime!).inSeconds < 100) {
      //set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CalendarTemplateViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        backgroundColor: Color(0xFFF4F5F6),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28))),
                child: SingleChildScrollView(
                  child: model.isBusy ? buildProgressIndicator() : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: buildTableCalendar(model)
                      ),
                      verticalSpaceSmall,
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildAddAppointmentToTemplateButton(model), buildSaveTemplateButton(model)
                          ]),
                      Visibility(
                        visible: model.addShowContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            //height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 4)),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Column(
                              children: [
                                buildDropdownStartHours(model),
                                buildDropdownEndHours(model),
                                buildDropdownRoom(model),
                                buildPriceInputText(model),
                                buildOkCancelButtonRow(model),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ...model.getSelectedEvents().map((appWrapper) {
                        int index =
                            model.getSelectedEvents().indexOf(appWrapper);

                        return GestureDetector(
                            onTap: () {
                              if (!model.isRedundantClick(DateTime.now()))
                                model.startEditingEvent(index);
                            },
                            child: Dismissible(
                              key: Key(appWrapper.hashCode.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) async {
                                return
                                    model.removeFromSelectedEvents(index);
                              },

                              background: Container(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                    child: Text(
                                      LocaleKeys
                                          .UI_CalendarView_desplazar_remover,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Poppins",
                                          color: Colors.black),
                                    ).tr(),
                                  ),
                                  decoration:
                                      BoxDecoration(color: Color(0xFFF4F5F6))),
                              child: Column(
                                children: [
                                  TimeAndDurationTemplate(
                                    time: appWrapper.wrapped.hora_inicio
                                        .toString(),
                                    fraction: Fraction(
                                            int.parse(appWrapper
                                                    .getFractionId()) +
                                                1,
                                            model.appointmentDuration)
                                        .fraction,
                                    price: appWrapper.wrapped.precio!,
                                  ),
                                ],
                              ),
                            ));
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      viewModelBuilder: () => CalendarTemplateViewModel(),
    );
  }

  // Se retorna el primer lunes de la presente semana
  DateTime _getFirstDay() {
    DateTime now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  // Se retorna el dia actual
  DateTime _getFocusedDay(CalendarTemplateViewModel model) {
    return model.getFocusedDay();
  }

  // Se retorna el próximo Domingo
  DateTime _getLastDay() {
    DateTime now = DateTime.now();
    int diff = 7 - now.weekday;
    return now.add(Duration(days: diff));
  }

  void _onDaySelected(
      DateTime selectedDay, DateTime focusedDay, CalendarTemplateViewModel model) {
    model.setFocusedDay(selectedDay);
  }

  Future<List<AppointmentWrapper>> _loadEvents(
      DateTime day, CalendarTemplateViewModel model) async {
    return await model.getEventsForDay(day);
  }

  Widget buildTableCalendar(CalendarTemplateViewModel model) {
    return TableCalendar(
      selectedDayPredicate: (day) {
        return isSameDay(model.getFocusedDay(), day);
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
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
      calendarFormat: CalendarFormat.week,
      calendarStyle: CalendarStyle(
          outsideTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800),
          weekendTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800),
          canMarkersOverflow: true,
          todayTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18.0,
              color: Colors.white),
          selectedTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18.0,
              color: Colors.white)),
      headerStyle: HeaderStyle(
        headerMargin: EdgeInsets.only(bottom: 16),
        leftChevronIcon: Icon(
          Icons.calendar_today,
          color: Color(0xFF334192),
          size: 35,
        ),
        decoration: BoxDecoration(color: Color(0xFFF4F5F6)),
        titleTextStyle:
        TextStyle(fontSize: 25, fontFamily: "Poppins"),
        formatButtonVisible: false,
        //centerHeaderTitle: true,
        formatButtonDecoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20.0),
        ),
        formatButtonTextStyle:
        TextStyle(color: Colors.white),
        formatButtonShowsNext: false,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        _onDaySelected(selectedDay, focusedDay, model);
      },

      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, day, focusedDay) =>
            Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0xFF334192),
                    borderRadius:
                    BorderRadius.circular(10.0)),
                child: Text(
                  day.day.toString(),
                  style: TextStyle(color: Colors.white),
                )),
        todayBuilder: (context, day, focusedDay) =>
            Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                    Colors.green, //Color(0xFF334192),
                    borderRadius:
                    BorderRadius.circular(10.0)),
                child: Text(
                  day.day.toString(),
                  style: TextStyle(color: Colors.white),
                )),
      ),
      //calendarController: _controller,
    );
  }

  Widget buildSaveTemplateButton(CalendarTemplateViewModel model) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          if (!model.isRedundantClick(DateTime.now()))
            model.persistTemplate();
        },
        dragStartBehavior: DragStartBehavior.start,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            height: 40,
            //width: 150,
            decoration: BoxDecoration(
                color: Color(0xFF334192),
                borderRadius:
                BorderRadius.all(Radius.circular(16))),
            child: Center(
                child: Text(
                    LocaleKeys
                        .UI_CalendarTemplateView_guardar_template,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600))
                    .tr()),
          ),
        ),
      ),
    );
  }

  Widget buildAddAppointmentToTemplateButton(CalendarTemplateViewModel model) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          model.startAddingEvent();
        },
        dragStartBehavior: DragStartBehavior.start,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            height: 40,
            //width: 120,
            decoration: BoxDecoration(
                color: Color(0xFF334192),
                borderRadius:
                BorderRadius.all(Radius.circular(16))),
            child: Center(
                child: Text(
                    LocaleKeys
                        .UI_CalendarTemplateView_agregar_turnos,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600))
                    .tr()),
          ),
        ),
      ),
    );
  }

  DropdownButton buildDropdownStartHours(CalendarTemplateViewModel model) {
    return DropdownButton<Hour>(
      value: model.getSelectedHourStart(),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      hint: Container(
        width: 200,
        child: Text(
            LocaleKeys
                .UI_CalendarView_elegir_hora,
            style:
            TextStyle(color: Colors.grey))
            .tr(),
      ),
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (Hour? newValue) {
        model.setSelectedHourStart(newValue);
      },
      items: model.start_hours
          .map<DropdownMenuItem<Hour>>(
              (Hour value) {
            return DropdownMenuItem<Hour>(
              value: value,
              child: Text(value.hour),
            );
          }).toList(),
    );
  }

  DropdownButton buildDropdownEndHours(CalendarTemplateViewModel model) {
    return DropdownButton<Hour>(
      value: model.getSelectedHourEnd(),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      hint: Container(
        width: 200,
        child: Text(
            LocaleKeys
                .UI_CalendarView_elegir_hora,
            style:
            TextStyle(color: Colors.grey))
            .tr(),
      ),
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (Hour? newValue) {
        model.setSelectedHourEnd(newValue);
      },
      items: model.getEndHours()
          .map<DropdownMenuItem<Hour>>(
              (Hour value) {
            return DropdownMenuItem<Hour>(
              value: value,
              child: Text(value.hour),
            );
          }).toList(),
    );
  }

  DropdownButton buildDropdownRoom(CalendarTemplateViewModel model) {
    return DropdownButton<Room>(
        value: model.getSelectedRoom(),
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        hint: Container(
          width: 200,
          child: Text(
              LocaleKeys
                  .UI_CalendarView_elegir_consultorio,
              style:
              TextStyle(color: Colors.grey))
              .tr(),
        ),
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (Room? newValue) {
          model.setSelectedRoom(newValue);
        },
        items: model.rooms
            .map<DropdownMenuItem<Room>>(
                (Room value) {
              return DropdownMenuItem<Room>(
                value: value,
                child: Text(value.room),
              );
            }).toList(),
      );
  }

  Widget buildOkCancelButtonRow(CalendarTemplateViewModel model) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          child: Text(LocaleKeys
              .UI_CalendarTemplateView_guardar)
              .tr(),
          onPressed: () {
            model.saveEvent();
          },
        ),
        TextButton(
            onPressed: () {
              if (!isRedundentClick(
                  DateTime.now())) {
                model.cancelAddingEvent();
              }
            },
            child: Text(LocaleKeys
                .UI_CalendarView_cancelar)
                .tr())
      ]
    );
  }

  Widget buildPriceInputText(CalendarTemplateViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        onChanged: (text) {
          model.setSelectedPrice(int.parse(text)); },
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: LocaleKeys.UI_CalendarTemplateView_enterPrice.tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 40.0),
        )
      )
    );
  }

  Widget buildProgressIndicator() {
    return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue));
  }

}
