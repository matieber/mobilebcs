import 'package:flutter/cupertino.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';

class FamilyMembersViewModel extends BaseViewModel {
  final _logger = getLogger('FamilyMembersViewModel');
  final _userService = locator<UserService>();
  StateSetter? _familyMemberState;
  List<PersonaACargo> _familyMembers =
      List<PersonaACargo>.empty(growable: true);
  PersonaACargo? _selectedFamilyMember;

  set familySelectorState(StateSetter familySelectorState) {
    _familyMemberState = familySelectorState;
  }

  FamilyMembersViewModel() {
    //runStartUpLogic();
  }

  PersonaACargo? get selectedFamilyMember => _selectedFamilyMember;

  set selectedFamilyMember(PersonaACargo? member) =>
      _selectedFamilyMember = member;

  get familyMembers => _familyMembers;

  void runStartUpLogic() async {
    _logger.d("Init");
    setBusy(true);
    await _userService.repopulateCurrentUser();
    Paciente user = _userService.currentUser!;
    PersonaACargo me = PersonaACargo(
        fullName: user.fullNameCap, relationship: "", dni: user.dni);
    _familyMembers.add(me);
    if (user.acargo != null) {
      _familyMembers.addAll(user.acargo!);
    }
    _selectedFamilyMember = me;
    notifyListeners();
    setBusy(false);
    notifyListeners();
  }
}
