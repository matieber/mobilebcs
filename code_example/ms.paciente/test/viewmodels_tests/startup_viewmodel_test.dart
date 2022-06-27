import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/ui/startup/startup_viewmodel.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helper_firestore.dart';
import '../helpers/test_helper_storage.dart';

import '../helpers/test_helpers.dart';

//import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
//import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flamingo/flamingo.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:flamingo_example/model/user.dart';
//import 'package:test/test.dart';

StartUpViewModel _getModel() => StartUpViewModel();

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupCloudFirestoreMocks();

  setupFirebaseStorageMocks();

  group('StartupViewmodelTest -', () {
    setUpAll(() async {
      const FirebaseOptions testOptions = FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      );

      String testAppName = 'foo';

      await Flamingo.initializeApp(name: testAppName, options: testOptions);
    });

    /*setUp(() async {
      clearInteractions(mock);
      Firebase.delegatePackingProperty = mock;

      final FirebaseAppPlatform platformApp =
          FirebaseAppPlatform(testAppName, testOptions);

      when(mock.apps).thenReturn([platformApp]);
      when(mock.app(testAppName)).thenReturn(platformApp);
      when(mock.initializeApp(name: testAppName, options: testOptions))
          .thenAnswer((_) {
        return Future.value(platformApp);
      });
      FirebaseApp initializedApp =
          await Firebase.initializeApp(name: testAppName, options: testOptions);

      await Flamingo.initializeApp(name: testAppName, options: testOptions);
      registerServices();
    });*/

    setUp(() => registerServices());
    tearDown(() => unregisterServices());

    group('runStartupLogic -', () {
      test(
          'When called should check if we have a logged in user on AuthenticationService',
          () async {
        final authenticationService = getAndRegisterAuthenticationService();
        final model = _getModel();
        await model.runStartUpLogic();

        //verifica que se llamo al metodo isUserLoggedIn
        verify(authenticationService.isUserLoggedIn());
      });

      test('When we have no logged in user, should navigate to the LoginView',
          () async {
        final navigationService = getAndRegisterNavigationService();
        var model = _getModel();
        await model.runStartUpLogic();

        verify(navigationService.replaceWith(Routes.loginView));
      });

      test(
          'When hasLoggedInUser is true, should get currentUser from userService',
          () async {
        final authenticationService =
            getAndRegisterAuthenticationService(isUserLoggedIn: true);
        final model = _getModel();
        await model.runStartUpLogic();

        verify(authenticationService.currentUser);
      });

      test(
          'When currentUser does NOT have default address, navigate to addressSelectionView',
          () async {
        final navigationService = getAndRegisterNavigationService();
        getAndRegisterAuthenticationService(isUserLoggedIn: true);
        final model = _getModel();
        await model.runStartUpLogic();

        verify(navigationService.navigateTo(Routes.addressSelectionView));
      });
    });
  });
}
