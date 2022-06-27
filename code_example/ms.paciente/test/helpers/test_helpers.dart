import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<AuthenticationService>(returnNullOnMissingStub: true),
  MockSpec<NavigationService>(returnNullOnMissingStub: true),
])
AuthenticationService getAndRegisterAuthenticationService({
  bool isUserLoggedIn = false,
  Paciente? currentUser,
}) {
  _removeRegistrationIfExists<AuthenticationService>();
  final service = MockAuthenticationService();
  when(service.isUserLoggedIn())
      .thenAnswer((_) async => Future.value(isUserLoggedIn));
  when(service.currentUser)
      .thenReturn(currentUser ?? Paciente(id: 'default_user'));
  locator.registerSingleton<AuthenticationService>(service);
  return service;
}

NavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

void registerServices() {
  getAndRegisterAuthenticationService();
  getAndRegisterNavigationService();
}

void unregisterServices() {
  locator.unregister<AuthenticationService>();
  locator.unregister<NavigationService>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
