import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mercadosalud/app/app.logger.dart';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helper_firestore.dart';
import '../helpers/test_helper_storage.dart';

import 'package:flamingo/flamingo.dart';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:mercadosalud/services/appointment_service.dart';
import 'package:mercadosalud/services/doctor_service.dart';
//import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

//import 'package:flamingo_example/model/user.dart';
//import 'package:test/test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupCloudFirestoreMocks();

  setupFirebaseStorageMocks();

  final firestore = MockFirestoreInstance();
  //final storage = MockFirebaseStorage();

  group('Flamingo Test -', () {
    setUpAll(() async {
      const FirebaseOptions testOptions = FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      );

      String testAppName = 'foo';

      await Flamingo.initializeApp(name: testAppName, options: testOptions);
      Flamingo.overrideWithSetting(firestoreInstance: firestore, rootPath: '/');
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

    group('User -', () {
      test('save load user/doctor', () async {
        final documentAccessor = DocumentAccessor();
        final user = Paciente(id: '2')..fullName = "perez";
        await documentAccessor.save(user);

        final doctor = Doctor(id: '2')..matricula = 100.toString();
        await documentAccessor.save(doctor);

        final user_sa =
            await documentAccessor.load<Paciente>(Paciente(id: '2'));
        final doctor_sa = await documentAccessor.load<Doctor>(Doctor(id: '2'));

        expect(user, equals(user_sa));
        expect(doctor, equals(doctor_sa));
        print(firestore.dump());
      });

      test('save load doctor appoinment template', () async {
        final documentAccessor = DocumentAccessor();
        final user = Paciente(id: '2')..fullName = "perez";
        await documentAccessor.save(user);

        final doctor_s = Doctor(id: '2')..matricula = 100.toString();
        await documentAccessor.save(doctor_s);

        final doctor = await documentAccessor.load<Doctor>(Doctor(id: '2'));
        print(firestore.dump());

        final ap1 = Appointment(collectionRef: doctor!.templateAppointment.ref)
          ..hora_inicio = "10";
        final ap2 = Appointment(collectionRef: doctor.templateAppointment.ref)
          ..hora_inicio = "11";

        final batch = Batch()
          //..update(doctor)
          ..save(ap1)
          ..save(ap2);
        await batch.commit();

        //expect(doctor, equals(doctor_sa));
        print(firestore.dump());
      });

      test('save load via doctor service doctor appoitnment template',
          () async {
        final _logger = getLogger('DoctorService');

        final documentAccessor = DocumentAccessor();
        final user = Paciente(id: '2')..fullName = "perez";
        await documentAccessor.save(user);

        final doctor = Doctor(id: '2')..matricula = 100.toString();
        await documentAccessor.save(doctor);

        print(firestore.dump());
        final ref = doctor.templateAppointment.ref;
        _logger.d("ref $ref");

        final ap1 = Appointment(collectionRef: doctor.templateAppointment.ref)
          ..hora_inicio = "10";
        final ap2 = Appointment(collectionRef: doctor.templateAppointment.ref)
          ..hora_inicio = "11";

        final _doc_serv = DoctorService();
        final list_o = [ap1, ap2];
        await _doc_serv.saveAppointments('2', list_o);
        //expect(doctor, equals(doctor_sa));
        print(firestore.dump());

        //final doctor2 = await documentAccessor.load<Doctor>(Doctor(id: '2'));
        //print(doctor2!.templateAppointment.path);

        final list_apps = await _doc_serv.getAppointments('2');
        print(list_apps);
        expect(list_o, equals(list_apps));
      });

      test('save appoimnet', () async {
        final documentAccessor = DocumentAccessor();
        final app = Appointment(id: '1')
          ..medico_id = "art"
          ..fecha = Timestamp.now();
        await documentAccessor.save(app);

        print(firestore.dump());

        final app2 =
            await documentAccessor.load<Appointment>(Appointment(id: '1'));

        //expect(user.toData(), equals(user3!.toData()));

        expect(app, equals(app2));

        final app_serv = new AppointmentService();
        final list = await app_serv.getAppointments("art", DateTime.now());
        print("lista: $list");
      });
    });
  });
}
