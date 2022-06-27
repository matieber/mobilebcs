import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/services/user_service.dart';
import 'package:mercadosalud/services/geo_service.dart';
import 'package:stacked/stacked.dart';
import 'package:location/location.dart';

class SearchFormViewModel extends BaseViewModel {
  /*
  static final Map<String, String> _specializationToDoctorNameTranslation = {
    'MEDICINA GENERAL': 'CLINICA MEDICA',
    'NINOS (PEDIATRIA)': 'PEDIATRIA',
    'CHOQUE (TRAUMATOLOGIA)	': 'TRAUMATOLOGIA',
    'REHABILITACION (KINESOLOGIA)': 'KINESOLOGIA',
    'REPRODUCCION (GINECOLOGIA)': 'GINECOLOGIA',
    'SALUD MENTAL (PSICOLOGIA)': 'PSICOLOGIA',
    'DIABETE (ENDOCRINOLOGIA)': 'ENDOCRINOLOGIA',
    'PESO (NUTRITICION)': 'NUTRICION',
    'CANCER (ONCOLOGIA)': 'ONCOLOGIA',
    'OJO / VISTA (OFTALMOLOGIA)': 'OFTALMOLOGIA',
    'CORAZON (CARDIOLOGIA)': 'CARDOLOGIA',
    'PULMONES (NEUMOLOGIA)': 'NEUMOLOGIA',
    'PIEL (DERMATOLOGIA)': 'DERMATOLOGIA',
    'DIENTE ( DENTISTA)': 'DENTISTA',
    'SONRIR (ORTODONCIA)': 'ORTODONCIA',
    'ENFERMERA': 'ENFERMERIA',
    'MAYORES (GERATRIA)': 'GERATRIA',
    'ESTOMAGO (GASTRO ENTERELOGIA)': 'GASTROENTEROLOGIA'
  };*/

  static final Map<String, String> _specializationToDoctorNameTranslation = {
    'MEDICINA GENERAL': 'CLINICA MEDICA',
    'NINOS (PEDIATRIA)': 'PEDIATRIA',
    'CHOQUE (TRAUMATOLOGIA)	': 'TRAUMATOLOGIA'
  };

  final _userService = locator<UserService>();
  final _geoService = locator<GeoService>();
  final _logger = getLogger('SearchFormViewModel');
  double _radius = 10.0;
  Map<String, bool> submodelsInitialization = {
    'searchLocation': false,
    'specializations': false,
  };

  Map<String, LatLng> geopoints = Map<String, LatLng>();
  LatLng? _searchLocation = null;
  late LatLng _myZone;

  String _selectedRegionOption = 'Mi domicilio';
  List<String> _regionOptionsList = [
    'Mi domicilio',
    'Mi ubicación',
    'Indicar en el mapa'
  ];

  late List<String> familyMembers = [];
  late String _selectedFamilyMember;

  late List<String> _specializationsList;
  late String _selectedSpecialization;

  SearchFormViewModel() {
    setBusy(true);
    loadGeoReferences();
    loadFamilyMemberInfo();
    loadSpecializations();

    //////
    //loadAddressGeoReference();
    ////
  }

  String get selectedRegionOption => _selectedRegionOption;

  set selectedRegionOption(String searchOption) {
    _selectedRegionOption = searchOption;
    _logger.d(_selectedRegionOption);
  }

  Iterable<String> get regionOptionsList =>
      _regionOptionsList; //geopoints.keys;

  String get selectedSpecialization => _selectedSpecialization;

  set selectedSpecialization(String newSpec) {
    _logger.d(_selectedSpecialization);
    _selectedSpecialization = newSpec;
  }

  Map<String, String> get specializationToDoctorNameTranslation =>
      _specializationToDoctorNameTranslation;

  List<String> get specializationsList => _specializationsList;

  String get selectedFamilyMember => _selectedFamilyMember;

  set selectedFamilyMember(String newMember) {
    _selectedFamilyMember = newMember;
    _logger.d(_selectedFamilyMember);
  }

  LatLng? get searchLocation => _searchLocation;

  Future<LatLng> _getPosition() async {
    final data = await Location().getLocation();
    return LatLng(data.latitude!, data.longitude!);
  }

  set searchLocation(LatLng? center) {
    _searchLocation = center;
  }

  set radius(double rad) => _radius = rad;

  double get radius => _radius;

  void loadSpecializations() {
    _specializationsList = _specializationToDoctorNameTranslation.keys.toList();
    _selectedSpecialization = _specializationsList.first;
    submodelsInitialization['specializations'] = true;
    allSubmodelsInitialized();
  }

  void loadGeoReferences() async {
    loadAddressGeoReference();
    loadCurrentPositionGeoReference();
  }

  void loadFamilyMemberInfo() {
    familyMembers.add(_userService.currentUser!.fullName!);
    _userService.currentUser!.acargo?.forEach((familiar) {
      familyMembers.add(familiar.fullName!);
    });
    _selectedFamilyMember = _userService.currentUser!.fullName!;

    submodelsInitialization['familyMember'] = true;
    allSubmodelsInitialized();
  }

  void loadAddressGeoReference() async {
    String city = _userService.currentUser!.address!.cityCap!;
    String street = _userService.currentUser!.address!.street!;
    String number = _userService.currentUser!.address!.number!.toString();
    await _geoService
        .locationFromAddress(street + " " + number + "," + city)
        .then((zonePosition) {
      _myZone = LatLng(
          zonePosition!.geopoint!.latitude, zonePosition.geopoint!.longitude);
      _searchLocation = _myZone;
      geopoints.putIfAbsent(
          LocaleKeys.UI_SearchFormView_mi_direccion, () => _myZone);
      setBusy(false);
    });
  }

  void loadCurrentPositionGeoReference() async {
    _getPosition().then((value) {
      geopoints.putIfAbsent(
          LocaleKeys.UI_SearchFormView_mi_ubicacion, () => value);
      submodelsInitialization['searchLocation'] = true;
      allSubmodelsInitialized();
    });
  }

  bool allSubmodelsInitialized() {
    bool ret = true;
    submodelsInitialization.values.forEach((element) {
      if (element == false) ret = false;
      return;
    });
    _logger.d(ret);
    if (ret) {
      setBusy(false);
      notifyListeners();
    }
    return ret;
  }
}
