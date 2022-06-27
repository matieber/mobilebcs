import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mercadosalud/ui/home/appointment/my_history_appointments_view.dart';
import 'package:mercadosalud/ui/home/search/search_form_view.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';
import 'appointment/my_appointments_view.dart';

class HomeView extends StatelessWidget {

  int? _focusedTab = null;
  HomeView({Key? key, int? focusedTab}){
    this._focusedTab = focusedTab;
  }

  int? get focusedTab => _focusedTab;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          reverse: model.reverse,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              child: child,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
            );
          },
          child: getViewForIndex(model.currentIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green[500],
          unselectedItemColor: Colors.white60,
          selectedItemColor: Colors.white,
          currentIndex: model.currentIndex,
          onTap: model.setIndex,
          items: [
            BottomNavigationBarItem(
              label: 'Buscar',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'Mis Turnos',
              icon: Icon(Icons.perm_contact_calendar),
            ),
            BottomNavigationBarItem(
              label: 'Cuenta',
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
      viewModelBuilder: () => HomeViewModel(focusedTab),
    );
  }

  Widget getViewForIndex(int index) {
    switch (index) {
      case 0:
        return SearchFormView();
      case 1:
        return MyAppointmentView();
      case 2:
        return MyHistoryAppointmentView();
      default:
        return SearchFormView();
    }
  }
}
