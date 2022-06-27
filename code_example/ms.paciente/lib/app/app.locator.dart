// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/appointment_service.dart';
import '../services/assignment_service.dart';
import '../services/authentication_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/doctor_service.dart';
import '../services/email_service.dart';
import '../services/geo_service.dart';
import '../services/price_service.dart';
import '../services/user_service.dart';
import '../utils/image_selector.dart';

final locator = StackedLocator.instance;

void setupLocator({String? environment, EnvironmentFilter? environmentFilter}) {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerSingleton(FirebaseAuthenticationService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => DoctorService());
  locator.registerLazySingleton(() => AppointmentService());
  locator.registerLazySingleton(() => AssignmentService());
  locator.registerLazySingleton(() => CloudStorageService());
  locator.registerLazySingleton(() => GeoService());
  locator.registerSingleton(PriceService());
  locator.registerLazySingleton(() => EmailService());
  locator.registerSingleton(ConnectivityService());
  locator.registerLazySingleton(() => ImageSelector());
}
