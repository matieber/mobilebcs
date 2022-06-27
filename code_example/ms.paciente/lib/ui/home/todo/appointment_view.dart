import 'package:flutter/material.dart';
import 'package:mercadosalud/ui/home/todo/appointment_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'calendar_view.dart';

class AppointmentView extends StatelessWidget {
  const AppointmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppointmentViewModel>.reactive(
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: Container(
            child: Column(
              children: [
                Expanded(child: CalendarView()),
              ],
            ),
          ),
        ),
      ),
      viewModelBuilder: () => AppointmentViewModel(),
    );
  }

  
}
