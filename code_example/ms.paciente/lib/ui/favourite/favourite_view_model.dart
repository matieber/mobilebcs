import 'package:flutter/material.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/services/doctor_service.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

class FavouriteViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final _doctorService = locator<DoctorService>();
  final _userService = locator<UserService>();
  final DialogService _dialogService = locator<DialogService>();

  final _logger = getLogger('FavouriteViewModel');

  List<FavouriteDoctor>? _doctors;
  List<FavouriteDoctor>? get doctors => _doctors;
  Map<String,FavouriteDoctor> favDoctorsIdMap = Map<String,FavouriteDoctor>();

  FavouriteViewModel() {
    _logger.d("FavouriteViewModel Constructor");
    setBusy(true);
    _doctors = _userService.currentUser!.favourites;
    _logger.d(_doctors);
    if (_doctors == null) {
      _doctors = [];
    }
    _doctors!.forEach((element) {favDoctorsIdMap[element.medicoId!]=element;});
    setBusy(false);
  }

  Future deleteDoctor(int index) async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
      title: LocaleKeys.UI_FavouriteView_borrado.tr(),
      description: LocaleKeys.UI_Shared_continuar.tr(),
      confirmationTitle: LocaleKeys.UI_Shared_yes.tr(),
      cancelTitle: LocaleKeys.UI_Shared_no.tr(),
    );

    if (dialogResponse!.confirmed) {
      var favouriteToDelete = _doctors![index];
      setBusy(true);
      _doctors?.removeAt(index);
      favDoctorsIdMap.remove(favouriteToDelete.medicoId);
      _userService.currentUser!.favourites = favDoctorsIdMap.values.toList();
      await _userService.updateUser(_userService.currentUser!);
      setBusy(false);
      notifyListeners();
    }
  }

  navigateToDoctorCalendar(int index) async{
    var favouritedoctor = _doctors![index];
    final Doctor doctor = await _doctorService.getDoctor(favouritedoctor.medicoId!);
    _navigationService.navigateTo(Routes.calendarView, arguments: CalendarViewArguments(doctor: doctor, searchCriteria: SearchFormViewModel()));
  }

  bool isFavourite(String? medico_id) {
    return favDoctorsIdMap.isNotEmpty && favDoctorsIdMap.containsKey(medico_id);
  }

  void setUnsetFavourite(Doctor? doctor) {
    setBusy(true);
    if (this.isFavourite(doctor!.id))
      favDoctorsIdMap.remove(doctor.id);
    else{
      favDoctorsIdMap[doctor.id] = FavouriteDoctor(
                                      especialidad: doctor.especialidad,
                                      fullName: doctor.fullName,
                                      tituloCortesia: doctor.titulo_cortesia,
                                      medicoId: doctor.id);
    }
    _userService.currentUser!.favourites =
                                              favDoctorsIdMap.values.toList();
    _userService.updateUser(_userService.currentUser!);
    setBusy(false);
    notifyListeners();
  }

}
