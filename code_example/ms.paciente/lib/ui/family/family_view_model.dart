import 'package:mercadosalud/app/app.locator.dart';

import 'package:mercadosalud/services/cloud_storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:logger/logger.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/app/app.logger.dart';

//import 'package:mercadosalud/services/firebase_authentication_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

class FamiltyViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final _firestoreService = locator<UserService>();
  final DialogService _dialogService = locator<DialogService>();
  final _firebaseAuthenticationService = locator<AuthenticationService>();

  final _logger = getLogger('FamiltyViewModel');

  List<PersonaACargo>? _persons;
  List<PersonaACargo>? get persons => _persons;

  FamiltyViewModel() {
    _logger.d("PostsViewModel Constructor");
  }

  Future runStartUpLogic() async {
    setBusy(true);
    _persons = _firebaseAuthenticationService.currentUser!.acargo;
    _logger.d(_persons);
    if (_persons == null) {
      //PersonaACargo p1 = PersonaACargo(fullName: "Pedro", relationship: "hijo");
      //PersonaACargo p2 = PersonaACargo(fullName: "Maria", relationship: "hija");
      _persons = [];
    }
    /*if (user_address != null) {
      final data = user_address.toData();

      //conversion de  int a String para numero
      data['number'] = data['number'].toString();
      data['phone'] = _firebaseAuthenticationService.currentUser!.phone;
      _logger.d(data);
      form.patchValue(data);
    }*/
    setBusy(false);
  }

  Future submitIfValid() async {
    //String address = form.fields['address']!.value;
    final updated_user = _firebaseAuthenticationService.currentUser!;

    updated_user.acargo = _persons;
    await _firestoreService.updateUser(updated_user);

    //_navigationService.replaceWith(Routes.startUpView);
    _navigationService.back();
  }

  Future deletePerson(int index) async {
    var dialogResponse = await _dialogService.showConfirmationDialog(
      title: 'Are you sure?',
      description: 'Do you really want to delete the post?',
      confirmationTitle: 'Yes',
      cancelTitle: 'No',
    );

    if (dialogResponse!.confirmed) {
      var postToDelete = _persons![index];
      setBusy(true);
      _persons?.removeAt(index);
      setBusy(false);
    }
  }

  Future navigateToCreateView() async {
    final nueva_persona = PersonaACargo(fullName: "", relationship: "");
    //_persons!.add(nueva_persona);
    await _navigationService.navigateTo(Routes.createPersonView,
        arguments: CreatePersonViewArguments(
            edittingPost: nueva_persona, persons: persons));
    notifyListeners();
  }

  Future editPerson(int index) async {
    //agregue CreatePostViewArguments sino daba exception cuando cambie de versiones...
    //
    await _navigationService.navigateTo(Routes.createPersonView,
        arguments: CreatePersonViewArguments(edittingPost: _persons![index]));

    notifyListeners();
  }
}
