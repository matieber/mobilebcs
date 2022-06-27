// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';

import '../ui/address_selection/address_selection_view.dart';
import '../ui/create_account/create_account_view.dart';
import '../ui/family/create_person/create_person_view.dart';
import '../ui/family/family_view.dart';
import '../ui/favourite/favourite_view.dart';
import '../ui/home/appointment/appointment_detail_view.dart';
import '../ui/home/appointment/my_appointments_view.dart';
import '../ui/home/appointment/my_history_appointments_view.dart';
import '../ui/home/home_view.dart';
import '../ui/home/search/search_form_view.dart';
import '../ui/home/search/search_form_viewmodel.dart';
import '../ui/home/search/search_results_tab_view.dart';
import '../ui/home/todo/calendar_view.dart';
import '../ui/login/login_view.dart';
import '../ui/recover_pass/recover_pass_view.dart';
import '../ui/startup/startup_view.dart';

class Routes {
  static const String startUpView = '/';
  static const String createAccountView = '/create-account-view';
  static const String homeView = '/home-view';
  static const String myHistoryAppointmentView = '/my-history-appointment-view';
  static const String loginView = '/login-view';
  static const String recoverPassView = '/recover-pass-view';
  static const String addressSelectionView = '/address-selection-view';
  static const String searchResultsTabView = '/search-results-tab-view';
  static const String calendarView = '/calendar-view';
  static const String searchFormView = '/search-form-view';
  static const String familtyView = '/familty-view';
  static const String createPersonView = '/create-person-view';
  static const String myAppointmentView = '/my-appointment-view';
  static const String favouriteView = '/favourite-view';
  static const String appointmentDetailView = '/appointment-detail-view';
  static const all = <String>{
    startUpView,
    createAccountView,
    homeView,
    myHistoryAppointmentView,
    loginView,
    recoverPassView,
    addressSelectionView,
    searchResultsTabView,
    calendarView,
    searchFormView,
    familtyView,
    createPersonView,
    myAppointmentView,
    favouriteView,
    appointmentDetailView,
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.startUpView, page: StartUpView),
    RouteDef(Routes.createAccountView, page: CreateAccountView),
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.myHistoryAppointmentView, page: MyHistoryAppointmentView),
    RouteDef(Routes.loginView, page: LoginView),
    RouteDef(Routes.recoverPassView, page: RecoverPassView),
    RouteDef(Routes.addressSelectionView, page: AddressSelectionView),
    RouteDef(Routes.searchResultsTabView, page: SearchResultsTabView),
    RouteDef(Routes.calendarView, page: CalendarView),
    RouteDef(Routes.searchFormView, page: SearchFormView),
    RouteDef(Routes.familtyView, page: FamiltyView),
    RouteDef(Routes.createPersonView, page: CreatePersonView),
    RouteDef(Routes.myAppointmentView, page: MyAppointmentView),
    RouteDef(Routes.favouriteView, page: FavouriteView),
    RouteDef(Routes.appointmentDetailView, page: AppointmentDetailView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    StartUpView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StartUpView(),
        settings: data,
      );
    },
    CreateAccountView: (data) {
      var args = data.getArgs<CreateAccountViewArguments>(
        orElse: () => CreateAccountViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => CreateAccountView(key: args.key),
        settings: data,
      );
    },
    HomeView: (data) {
      var args = data.getArgs<HomeViewArguments>(
        orElse: () => HomeViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => HomeView(
          key: args.key,
          focusedTab: args.focusedTab,
        ),
        settings: data,
      );
    },
    MyHistoryAppointmentView: (data) {
      var args = data.getArgs<MyHistoryAppointmentViewArguments>(
        orElse: () => MyHistoryAppointmentViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => MyHistoryAppointmentView(key: args.key),
        settings: data,
      );
    },
    LoginView: (data) {
      var args = data.getArgs<LoginViewArguments>(
        orElse: () => LoginViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => LoginView(key: args.key),
        settings: data,
      );
    },
    RecoverPassView: (data) {
      var args = data.getArgs<RecoverPassViewArguments>(
        orElse: () => RecoverPassViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => RecoverPassView(key: args.key),
        settings: data,
      );
    },
    AddressSelectionView: (data) {
      var args = data.getArgs<AddressSelectionViewArguments>(
        orElse: () => AddressSelectionViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => AddressSelectionView(key: args.key),
        settings: data,
      );
    },
    SearchResultsTabView: (data) {
      var args = data.getArgs<SearchResultsTabViewArguments>(nullOk: false);
      return CupertinoPageRoute<dynamic>(
        builder: (context) => SearchResultsTabView(
          key: args.key,
          searchModel: args.searchModel,
        ),
        settings: data,
      );
    },
    CalendarView: (data) {
      var args = data.getArgs<CalendarViewArguments>(
        orElse: () => CalendarViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => CalendarView(
          key: args.key,
          doctor: args.doctor,
          searchCriteria: args.searchCriteria,
        ),
        settings: data,
      );
    },
    SearchFormView: (data) {
      var args = data.getArgs<SearchFormViewArguments>(
        orElse: () => SearchFormViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => SearchFormView(key: args.key),
        settings: data,
      );
    },
    FamiltyView: (data) {
      return CupertinoPageRoute<dynamic>(
        builder: (context) => const FamiltyView(),
        settings: data,
      );
    },
    CreatePersonView: (data) {
      var args = data.getArgs<CreatePersonViewArguments>(
        orElse: () => CreatePersonViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => CreatePersonView(
          key: args.key,
          edittingPost: args.edittingPost,
          persons: args.persons,
        ),
        settings: data,
      );
    },
    MyAppointmentView: (data) {
      var args = data.getArgs<MyAppointmentViewArguments>(
        orElse: () => MyAppointmentViewArguments(),
      );
      return CupertinoPageRoute<dynamic>(
        builder: (context) => MyAppointmentView(key: args.key),
        settings: data,
      );
    },
    FavouriteView: (data) {
      return CupertinoPageRoute<dynamic>(
        builder: (context) => const FavouriteView(),
        settings: data,
      );
    },
    AppointmentDetailView: (data) {
      var args = data.getArgs<AppointmentDetailViewArguments>(nullOk: false);
      return CupertinoPageRoute<dynamic>(
        builder: (context) =>
            AppointmentDetailView(assignment: args.assignment),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// CreateAccountView arguments holder class
class CreateAccountViewArguments {
  final Key? key;
  CreateAccountViewArguments({this.key});
}

/// HomeView arguments holder class
class HomeViewArguments {
  final Key? key;
  final int? focusedTab;
  HomeViewArguments({this.key, this.focusedTab});
}

/// MyHistoryAppointmentView arguments holder class
class MyHistoryAppointmentViewArguments {
  final Key? key;
  MyHistoryAppointmentViewArguments({this.key});
}

/// LoginView arguments holder class
class LoginViewArguments {
  final Key? key;
  LoginViewArguments({this.key});
}

/// RecoverPassView arguments holder class
class RecoverPassViewArguments {
  final Key? key;
  RecoverPassViewArguments({this.key});
}

/// AddressSelectionView arguments holder class
class AddressSelectionViewArguments {
  final Key? key;
  AddressSelectionViewArguments({this.key});
}

/// SearchResultsTabView arguments holder class
class SearchResultsTabViewArguments {
  final Key? key;
  final SearchFormViewModel searchModel;
  SearchResultsTabViewArguments({this.key, required this.searchModel});
}

/// CalendarView arguments holder class
class CalendarViewArguments {
  final Key? key;
  final Doctor? doctor;
  final SearchFormViewModel? searchCriteria;
  CalendarViewArguments({this.key, this.doctor, this.searchCriteria});
}

/// SearchFormView arguments holder class
class SearchFormViewArguments {
  final Key? key;
  SearchFormViewArguments({this.key});
}

/// CreatePersonView arguments holder class
class CreatePersonViewArguments {
  final Key? key;
  final PersonaACargo? edittingPost;
  final List<PersonaACargo>? persons;
  CreatePersonViewArguments({this.key, this.edittingPost, this.persons});
}

/// MyAppointmentView arguments holder class
class MyAppointmentViewArguments {
  final Key? key;
  MyAppointmentViewArguments({this.key});
}

/// AppointmentDetailView arguments holder class
class AppointmentDetailViewArguments {
  final Assignment assignment;
  AppointmentDetailViewArguments({required this.assignment});
}
