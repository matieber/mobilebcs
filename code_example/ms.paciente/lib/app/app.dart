import 'package:mercadosalud/services/assignment_service.dart';
import 'package:mercadosalud/services/geo_service.dart';
import 'package:mercadosalud/services/price_service.dart';
import 'package:mercadosalud/ui/create_account/create_account_view.dart';
import 'package:mercadosalud/ui/favourite/favourite_view.dart';
import 'package:mercadosalud/ui/home/appointment/appointment_detail_view.dart';
import 'package:mercadosalud/ui/home/appointment/my_appointments_view.dart';
import 'package:mercadosalud/ui/home/appointment/my_history_appointments_view.dart';
import 'package:mercadosalud/ui/home/search/search_form_view.dart';
import 'package:mercadosalud/ui/home/search/search_results_tab_view.dart';
import 'package:mercadosalud/ui/home/todo/calendar_view.dart';
import 'package:mercadosalud/ui/login/login_view.dart';
import 'package:mercadosalud/ui/recover_pass/recover_pass_view.dart';
import 'package:mercadosalud/ui/address_selection/address_selection_view.dart';
import 'package:mercadosalud/ui/home/home_view.dart';
import 'package:mercadosalud/ui/family/family_view.dart';
import 'package:mercadosalud/ui/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/services/connectivity_service.dart';
import 'package:mercadosalud/services/doctor_service.dart';
import 'package:mercadosalud/services/appointment_service.dart';
import 'package:mercadosalud/services/cloud_storage_service.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/utils/image_selector.dart';
import 'package:mercadosalud/ui/family/create_person/create_person_view.dart';
import 'package:mercadosalud/services/email_service.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: StartUpView, initial: true),
    CupertinoRoute(page: CreateAccountView),
    CupertinoRoute(page: HomeView),
    CupertinoRoute(page: MyHistoryAppointmentView),
    CupertinoRoute(page: LoginView),
    CupertinoRoute(page: RecoverPassView),
    CupertinoRoute(page: AddressSelectionView),
    CupertinoRoute(page: SearchResultsTabView),
    CupertinoRoute(page: CalendarView),
    CupertinoRoute(page: SearchFormView),
    CupertinoRoute(page: FamiltyView),
    CupertinoRoute(page: CreatePersonView),
    CupertinoRoute(page: MyAppointmentView),
    CupertinoRoute(page: FavouriteView),
    CupertinoRoute(page: AppointmentDetailView)
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    Singleton(classType: FirebaseAuthenticationService),
    LazySingleton(classType: AuthenticationService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: DoctorService),
    LazySingleton(classType: AppointmentService),
    LazySingleton(classType: AssignmentService),
    LazySingleton(classType: CloudStorageService),
    LazySingleton(classType: GeoService),
    Singleton(classType: PriceService),
    LazySingleton(classType: EmailService),
    Singleton(classType: ConnectivityService),
    LazySingleton(classType: ImageSelector),
  ],
  logger: StackedLogger(),
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
