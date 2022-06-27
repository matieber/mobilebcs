//import 'package:mercadosalud/services/firebase_authentication_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/services/doctor_service.dart';

class AuthenticationService {
  final _firebaseAuthenticationService =
      locator<FirebaseAuthenticationService>();
  final UserService _userService = locator<UserService>();
  final _doctorService = locator<DoctorService>();

  final _logger = getLogger('AuthenticationService');

  FirebaseAuthenticationResult? _authenticationResult;

  Paciente? get currentUser => _userService.currentUser;

  String? get userUidold {
    final uid = _authenticationResult!.user!.uid;
    _logger.d("User uid: $uid");
    if (_firebaseAuthenticationService.hasUser)
      return _authenticationResult!.user!.uid;
    else
      return null;
  }

  Future<FirebaseAuthenticationResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _authenticationResult =
          await _firebaseAuthenticationService.loginWithEmail(
        email: email,
        password: password,
      );
      if (!_authenticationResult!.hasError) {
        await _populateCurrentUser(_authenticationResult!.user!.uid!);
        bool emailVerified =
            _firebaseAuthenticationService.currentUser!.emailVerified;
        if (!emailVerified) {
          await _firebaseAuthenticationService.currentUser!
              .sendEmailVerification();
          return FirebaseAuthenticationResult.error(
              errorMessage: LocaleKeys.API_email_no_validado.tr());
        }
      }
      return _authenticationResult!;
    } on Exception catch (e) {
      _logger.e('A general exception has occured. $e');
      return FirebaseAuthenticationResult.error(
          errorMessage: LocaleKeys.API_cannot_login.tr());
    }
  }

  Future<FirebaseAuthenticationResult> signInWithGoogle() async {
    try {
      _authenticationResult =
          await _firebaseAuthenticationService.signInWithGoogle();

      if (!_authenticationResult!.hasError) {
        final exists_user =
            await _userService.existUser(_authenticationResult!.user!.uid);
        _logger.d("Existe ususario: $exists_user");

        if (!exists_user) {
          await _populateCurrentUser(_authenticationResult!.user!.uid!,
              auth_user: _authenticationResult!);
        }
      }

      return _authenticationResult!;
    } on Exception catch (e) {
      _logger.e('A general exception has occured. $e');
      return FirebaseAuthenticationResult.error(
          errorMessage: LocaleKeys.API_cannot_login.tr());
    }
  }

  Future<void> logout() async {
    try {
      _authenticationResult = await _firebaseAuthenticationService.logout();
      _userService.clearCurrentuser();
    } catch (e) {
      _logger.d(e);
      return null;
    }
  }

  Future _populateCurrentUser(String uid,
      {FirebaseAuthenticationResult? auth_user}) async {
    //si user no tiene documneto en user lo creo
    _logger.d("Populate $uid");
    if (!await _userService.existUser(uid)) {
      final new_user = Paciente(id: uid);
      //si tiene perfil de doctor traigo datos
      if (await _doctorService.existDoctor(uid)) {
        _logger.d("Migrating data from Doctor $uid");
        final Doctor doc = await _doctorService.getDoctor(uid);
        new_user.email = doc.email;
        new_user.fullName = doc.fullName;
        new_user.address = doc.address;
        new_user.phone = doc.phone;
        new_user.sex = doc.sex;
        new_user.dni = doc.dni;
        new_user.selfie = doc.selfie;
      } else if (auth_user != null) {
        new_user.email = auth_user.user!.email;
        new_user.fullName = auth_user.user!.displayName;
      }
      _logger.d(new_user.toData());
      await _userService.createUser(new_user);
    }
    await _userService.populateCurrentUser(uid);
  }

  Future<bool> isUserLoggedIn() async {
    var user = _firebaseAuthenticationService.currentUser;
    if (user != null) await _populateCurrentUser(user.uid);
    return user != null;
  }

  Future<FirebaseAuthenticationResult?> createAccountWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    try {
      _authenticationResult =
          await _firebaseAuthenticationService.createAccountWithEmail(
        email: email,
        password: password,
      );
      final new_user = Paciente(id: _authenticationResult!.user!.uid!)
        ..email = email
        ..fullName = fullName;

      await _userService.createUser(new_user);

      return _authenticationResult;
    } catch (e) {
      _logger.d(e);
      return null;
    }
  }
}
