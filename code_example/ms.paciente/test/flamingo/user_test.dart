import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helper_firestore.dart';
import '../helpers/test_helper_storage.dart';

import 'package:flamingo/flamingo.dart';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:mercadosalud/services/appointment_service.dart';
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
      test('save load user', () async {
        final documentAccessor = DocumentAccessor();
        final user = Paciente(id: '1')..fullName = "prueba";
        await documentAccessor.save(user);

        print(firestore.dump());

        final user3 = await documentAccessor.load<Paciente>(Paciente(id: '1'));
        print(user.collectionPath);

        //expect(user.toData(), equals(user3!.toData()));

        final user22 = Paciente(id: '1')..fullName = "prueba";
        expect(user, equals(user22));
        expect(user, equals(user3));
      });
      /*test('firestore directo', () async {
        print("------------------");
        await firestore.collection('usersNuevo').add({
          'username': 'Bob',
        });
        final snapshot = await firestore.collection('usersNuevo').get();
        print(snapshot.docs.length); // 1
        print(snapshot.docs.first.get('username')); // 'Bob'
        print(firestore.dump());
      });*/

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
