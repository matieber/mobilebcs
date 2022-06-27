
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/services/appointment_service.dart';
import 'package:mercadosalud/services/doctor_service.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';

class AppointmentDetailViewModel extends BaseViewModel{

  Doctor? _doctor;
  Appointment? _appointment;
  late Assignment? _assignment;

  final _doctorService = locator<DoctorService>();
  final _appointmentService = locator<AppointmentService>();

  AppointmentDetailViewModel(Assignment this._assignment){
    setBusy(true);

    _doctorService.getDoctor(this._assignment!.medico_id!).then((value)
    {
      _doctor = value;
      if (appointment != null ) {
        setBusy(false);
        notifyListeners();
      }
    });

    _appointmentService.getAppointment(this._assignment!.turno_id!).then((value)
    {
      _appointment = value;
      if (doctor != null){
        setBusy(false);
        notifyListeners();
      }
    });
  }

  get assignment => this._assignment;

  set doctor(Doctor? doctor) => _doctor = doctor;
  Doctor? get doctor => _doctor;

  set appointment(Appointment? appointment) => _appointment = appointment;
  Appointment? get appointment => _appointment;


}