import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/services/appointment_service.dart';
import 'package:mercadosalud/services/price_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:mercadosalud/services/doctor_service.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SearchResultsTabViewModel extends StreamViewModel<List<Doctor?>> {
  final _doctorService = locator<DoctorService>();
  final _appointmentService = locator<AppointmentService>();
  late List<Doctor?> _doctors;
  SearchFormViewModel searchCriteria;
  final _logger = getLogger('SearchResultsTabViewModel');
  bool _processed = false;

  SearchResultsTabViewModel({required this.searchCriteria});

  bool get priceReady => _processed;
  bool get dataReady => super.dataReady && priceReady;

  Future<void> onData(List<Doctor?>? data) async {
    _processed = false;
    final toRemove = [];
    _logger.d("processed $_processed");
    for (var doctor in data!) {
      _logger.d("In: $doctor");
      final appointments = await getDoctorFreeAppointmentsPreview(doctor!);
      if (appointments.isEmpty) {
        toRemove.add(doctor);
        print(
            "${doctor.id} was removed from doctors stream because it has no appointments");
      } else {
        appointments.sort((Appointment a1, Appointment a2) {
          if (a1.fecha!.microsecondsSinceEpoch >
              a2.fecha!.microsecondsSinceEpoch) return 1;
          if (a1.fecha!.microsecondsSinceEpoch <
              a2.fecha!.microsecondsSinceEpoch) return -1;
          final a1_hora = int.parse(a1.hora_inicio!.split(":").first);
          final a2_hora = int.parse(a2.hora_inicio!.split(":").first);

          if (a1_hora > a2_hora) return 1;
          if (a1_hora < a2_hora) return -1;

          final a1_min = int.parse(a1.turno_id!.split("_").last) * a1.duracion!;
          final a2_min = int.parse(a2.turno_id!.split("_").last) * a2.duracion!;

          if (a1_min > a2_min) return 1;
          if (a1_min < a2_min) return -1;

          return 0;
        });
        doctor.recentAppointments = appointments;
        doctor.minPrice = appointments
            .reduce((value, element) =>
                value.precio! < element.precio! ? value : element)
            .precio!;
        _logger.d("!!!!!!-1 Doctor ${doctor.id}  minprice: ${doctor.minPrice}");
      }
      _logger.d("Out: $doctor");
    }
    toRemove.forEach((doctor) {
      data.remove(doctor);
    });
    _processed = true;
    notifyListeners();
    _logger.d("processed $_processed");

    super.onData(data);
  }

  Future<void> processPriceDoctor(List<Doctor?> data) async {
    _processed = false;
    _logger.d("processed $_processed");
    for (var doctor in data) {
      _logger.d("In: $doctor");
      final appointments = await getDoctorFreeAppointmentsPreview(doctor!);
      if (appointments.isEmpty) {
        data.remove(doctor);
        print(
            "${doctor.id} was removed from doctors stream because it has no appointments");
      } else {
        doctor.recentAppointments = appointments;
        doctor.minPrice = appointments
            .reduce((value, element) =>
                value.precio! < element.precio! ? value : element)
            .precio!;
        _logger.d("!!!!!!-1 Doctor ${doctor.id}  minprice: ${doctor.minPrice}");
      }
      _logger.d("Out: $doctor");
    }
    _processed = true;
    notifyListeners();
    _logger.d("processed $_processed");
  }

  Future<List<Appointment>> getDoctorFreeAppointmentsPreview(Doctor d) async {
    DateTime initDate = DateTime.now();
    DateTime endDate = initDate;
    endDate = endDate.add(Duration(days: 30));
    final apps = await _appointmentService.getAppointmentsForDateRange(
        d.id, initDate, endDate, 20);
    return apps;
  }

  @override
  Stream<List<Doctor?>> get stream => _doctorService.fetchGeoDoctorsList(
      specialization: searchCriteria.specializationToDoctorNameTranslation[
          searchCriteria.selectedSpecialization]!,
      searchLocation: searchCriteria.searchLocation!,
      radius: searchCriteria.radius);

  Stream<List<Doctor>> get stream_AtLeastOne =>
      _doctorService.fetchGeoDoctorsList_AtLeastOne(
          specialization: searchCriteria.specializationToDoctorNameTranslation[
              searchCriteria.selectedSpecialization]!,
          searchLocation: searchCriteria.searchLocation!,
          radius: 100,
          limit: 1);

  @override
  void dispose() {
    super.dispose();
  }
}

class Price extends BaseViewModel {
  Doctor _doctor;
  String _minPrice = "";
  final _priceService = locator<PriceService>();
  final _logger = getLogger('Price - Search ResultsTab');

  Price(this._doctor) {
    setBusy(true);
    _logger.d("!!!!1Doctor ${_doctor.id}  minprice: ${_doctor.minPrice}");
    _logger.d(
        "!!!!2Doctor ${this._doctor.id}  minprice: ${this._doctor.minPrice}");
    if (this._doctor.minPrice != null) {
      if (this._doctor.minPrice! >= 0)
        _minPrice = this._doctor.minPrice.toString();
      else {
        Appointment cheaper = this._doctor.recentAppointments!.reduce(
            (app1, app2) =>
                this.getAppointmentPrice(app1) <= this.getAppointmentPrice(app2)
                    ? app1
                    : app2);
        _logger.d("Cheaper appointment: ${cheaper}");
        _minPrice = this.getAppointmentPrice(cheaper).toString();
      }
    }

    setBusy(false);
    notifyListeners();
  }

  /*return the appointment price irrespective of it is dynamic or not*/
  int getAppointmentPrice(Appointment appointment) {
    int ret = 999999;
    try {
      if (appointment.precio! >= 0)
        ret = appointment.precio!;
      else if (appointment.precio! < 0) {
        int weekday = appointment.fecha!.toDate().weekday;
        int start_hour = int.parse(appointment.hora_inicio!.split(":")[0]);
        ret = _priceService.getPrice(
            _doctor.especialidad ?? "",
            weekday,
            start_hour,
            _doctor.address!.comuna ?? "",
            _doctor.address!.city ?? "");
      }
      return ret;
    } catch (e) {
      print(
          "Something went wrong when getting AppointmentPrice" + e.toString());
    } finally {
      return ret;
    }
  }

  String get minPrice => _minPrice;
}
