import 'dart:async';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:flamingo/flamingo.dart';

import 'package:mercadosalud/utils/geoflutterfire/my_collection.dart';
import 'package:mercadosalud/utils/geoflutterfire/my_point.dart';

import 'appointment_service.dart';

class DoctorService {

  final _logger = getLogger('DoctorService');
  final _appointmentService = locator<AppointmentService>();

  Future existDoctor(String uid) async {
    try {
      final path = Document.path<Doctor>();
      final snapShot = await firestoreInstance.collection(path).doc(uid).get();

      return snapShot.exists;
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future getDoctor(String uid) async {
    try {
      final documentAccessor = DocumentAccessor();
      return await documentAccessor.load<Doctor>(Doctor(id: uid));
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future<List<Appointment>?> getAppointments(String medico_id) async {
    try {
      final documentAccessor = DocumentAccessor();
      final doctor = await documentAccessor.load<Doctor>(Doctor(id: medico_id));
      _logger.d("$medico_id");
      // Get sub collection
      final path = doctor!.templateAppointment.ref.path;
      _logger.d("path $path");
      final snapshot = await firestoreInstance.collection(path).get();
      final list =
          snapshot.docs.map((item) => Appointment(snapshot: item)).toList();

      _logger.d("$medico_id template: $list");
      return list;
    } catch (e) {
      _logger.d("$medico_id  template exception!!! ");
      logError(e);
      return null;
    }
  }

  Future<bool> deleteAppointments(String medico_id) async {
    try {
      _logger.d("medico_id: $medico_id");
      final documentAccessor = DocumentAccessor();
      final doctor = await documentAccessor.load<Doctor>(Doctor(id: medico_id));
      _logger.d("doctor: $doctor");
      // Get sub collection
      final path = doctor!.templateAppointment.ref.path;
      final snapshot =
          await firestoreInstance.collection(path).doc(medico_id).delete();
      return true;
    } catch (e) {
      _logger.d("$medico_id  template exception!!! ");
      logError(e);
      return false;
    }
  }

  Future<bool> saveAppointments(
      String medico_id, List<Appointment> list) async {
    try {
      final documentAccessor = DocumentAccessor();
      final doctor = await documentAccessor.load<Doctor>(Doctor(id: medico_id));
      _logger.d("$medico_id");

      final list_updated = [];
      list.forEach((element) {
        var ap = Appointment(
            id: medico_id,
            values: element.toData(),
            collectionRef: doctor!.templateAppointment.ref);
        list_updated.add(ap);
      });

      final batch = Batch();
      //si Appointment ya viene creado con i y red se puede evitar la creacion de nuevos objetos
      list_updated.forEach((element) {
        final data_ele = element.toData();
        _logger.d("data: $data_ele");
        batch.save(element);
      });

      await batch.commit();
      return true;
    } catch (e) {
      logError(e);
      return false;
    }
  }

  void logError(Object e) {
    String? errorMsg;
    if (e is PlatformException) {
      errorMsg = e.message;
    } else if (e is Exception) {
      errorMsg = e.toString();
    }
    print(errorMsg);
    _logger.e(errorMsg);
  }

  Stream<List<Doctor>> fetchGeoDoctorsList(
      {required String specialization,
      required LatLng searchLocation,
      required double radius}) async* {
    GeoFirePoint center =
        GeoFirePoint(searchLocation.latitude, searchLocation.longitude);

    _logger.d("Geohash for search center: " + center.hash);

    _logger.d("Especialidad: $specialization");
    final collectionReference = firestoreInstance
        .collection('doctor')
        .where("especialidad", isEqualTo: specialization)
        .where("enabled", isEqualTo: true);

    var snapshots = GeoFireCollectionRef(collectionReference).within(
        center: center, radius: radius, field: 'position', strictMode: true); //

    await for (final snapshot in snapshots) {
      final events = await snapshot.map((document) {
        Doctor? d = Doctor(
            snapshot: document as DocumentSnapshot<Map<String, dynamic>>);
        return d;
      }).toList();
      yield events;
      if (events.length == 0) {
        print(
            "No hay doctores para esa busqueda con radio=" + radius.toString());
        _logger.d(
            "No hay doctores para esa busqueda con radio=" + radius.toString());
      }
    }
  }

  Stream<List<Doctor>> fetchGeoDoctorsList_AtLeastOne(
      {required String specialization,
      required LatLng searchLocation,
      required double radius,
      int limit = 1}) async* {
    GeoFirePoint center =
        GeoFirePoint(searchLocation.latitude, searchLocation.longitude);

    _logger.d("Geohash for search center: " + center.hash);

    final collectionReference = firestoreInstance
        .collection('doctor')
        .where("especialidad", isEqualTo: specialization)
        .where("enabled", isEqualTo: true);

    final snapshots = GeoFireCollectionRef(collectionReference).within_AtLeast(
        center: center,
        radius: radius,
        field: 'position',
        strictMode: true,
        limit: 1);
    await for (final snapshot in snapshots) {
      final events = await snapshot.map((document) {
        Doctor? d = Doctor(
            snapshot: document as DocumentSnapshot<Map<String, dynamic>>);
        return d;
      }).toList();
      yield events;
    }
  }
}
