import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'calendar_template_view.dart';
import 'appointment_template_viewmodel.dart';

class AppointmentTemplateView extends StatelessWidget {
  const AppointmentTemplateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AppointmentTemplateViewModel>.reactive(
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: Container(
            child: Column(
              children: [
                Expanded(child: CalendarTemplateView()),
              ],
            ),
          ),
        ),
      ),
      viewModelBuilder: () => AppointmentTemplateViewModel(),
    );
  }

  
}
