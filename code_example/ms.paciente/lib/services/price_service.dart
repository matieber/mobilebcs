import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:flamingo/flamingo.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PriceService {
  final _logger = getLogger('PriceService');

  static const String day_hour_factors = 'day_hour_factors';
  static const String city_comuna_factors = 'city_comuna_factors';
  static const String prices = 'prices';
  static const int inicio_turno = 8;
  static const int fin_turno = 20;
  static const int rounded_mod = 100;

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
  };

  //para calculo precio
  Map<String, Map<String, dynamic>>? _dia_hora_precio;
  Map<String, double>? especialidad_precio;
  Map<String, double>? ciudad_comuna_precio;

  //para edicion
  List<PlutoRow>? _day_hour_rows;
  List<PlutoRow>? _price_rows;
  List<PlutoRow>? _city_comuna_rows;
  PriceService() {}

  CollectionPagingListener<Matrix>? collectionPagingListener;

  List<PlutoRow>? get getDayHourRows => _day_hour_rows;

  List<PlutoRow>? get getPriceRows => _price_rows;

  List<PlutoRow>? get getCityComunaRows => _city_comuna_rows;

  double _getCiudadComunaFactor(String city, String comuna) {
    final String key1 = city + '_' + comuna;
    final String key2 = city + '_';
    if (ciudad_comuna_precio!.containsKey(key1))
      return ciudad_comuna_precio![key1]!;
    else if (ciudad_comuna_precio!.containsKey(key2))
      return ciudad_comuna_precio![key2]!;
    else
      return 1.0;
  }

  double _getEspecialidadPrecio(String especialidad) {
    return especialidad_precio![especialidad]!;
  }

  double _getDiaHoraFactor(int diaSemana, int hour) {
    return _dia_hora_precio![hour.toString()]![diaSemana.toString()]
        .value
        .toDouble();
  }

  void dispose() async {
    await collectionPagingListener!.dispose();
  }

  void _initialize() {
    Query<Map<String, dynamic>> query = Matrix().collectionRef;

    collectionPagingListener = CollectionPagingListener<Matrix>(
      query: query,
      initialLimit: 5,
      pagingLimit: 5,
      decode: (snap) => Matrix(snapshot: snap),
    )..fetch();

    collectionPagingListener!.docChanges.listen((event) {
      for (var item in event) {
        final change = item.docChange;
        _logger.d(item.runtimeType);
        _logger.d(
            'id: ${item.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
        _logger.d("Antes: " +
            getPrice("TRAUMATOLOGIA", 1, 11, "", "Tandil").toString());
        if (item.doc.id == prices) _loadPrice(item.doc);
        if (item.doc.id == day_hour_factors) _loadDayHours(item.doc);
        if (item.doc.id == city_comuna_factors) _loadCityComuna(item.doc);
        _logger.d("despues: " +
            getPrice("TRAUMATOLOGIA", 1, 11, "", "Tandil").toString());
      }
    });
  }

  Future<void> initialize() async {
    final documentAccessor = DocumentAccessor();

    final mat_price = await documentAccessor.load<Matrix>(Matrix(id: prices));
    _loadPrice(mat_price!);

    final mat_dayhour =
        await documentAccessor.load<Matrix>(Matrix(id: day_hour_factors));
    _loadDayHours(mat_dayhour!);

    final mat_citycom =
        await documentAccessor.load<Matrix>(Matrix(id: city_comuna_factors));
    _loadCityComuna(mat_citycom!);

    _initialize();
  }

  void _loadDayHours(Matrix mat) {
    _day_hour_rows = getPlutoRows(mat);

    _dia_hora_precio = {};

    _day_hour_rows!.forEach((row) {
      PlutoRow prow = row;
      final PlutoCell hora = prow.cells['hora']!;
      _dia_hora_precio![hora.value.toString()] = prow.cells;
    });
  }

  void _loadCityComuna(Matrix mat) async {
    _city_comuna_rows = getPlutoRows(mat);

    getPlutoRows(mat);
    ciudad_comuna_precio = {};

    _city_comuna_rows!.forEach((row) {
      PlutoRow prow = row;
      final PlutoCell city = prow.cells['city']!;
      final PlutoCell comuna = prow.cells['comuna']!;
      final PlutoCell price = prow.cells['price']!;
      final String key = city.value + '_' + comuna.value;
      ciudad_comuna_precio![key] = price.value.toDouble();
    });
  }

  void _loadPrice(Matrix mat) {
    _price_rows = getPlutoRows(mat);
    especialidad_precio = {};

    _price_rows!.forEach((row) {
      PlutoRow prow = row;
      final PlutoCell especialidad = prow.cells['speciality']!;
      final PlutoCell price = prow.cells['price']!;
      especialidad_precio![especialidad.value.toString()] =
          price.value.toDouble();
    });
  }

  int _roundedPrice(double price) {
    final _price_temp = price.toInt();
    return _price_temp - _price_temp % PriceService.rounded_mod;
  }

  int getPrice(String especialidad, int diaSemana, int hour, String comuna,
      String ciudad) {
    return _roundedPrice(
        _getPrice(especialidad, diaSemana, hour, comuna, ciudad));
  }

  double _getPrice(String especialidad, int diaSemana, int hour, String comuna,
      String ciudad) {
    try {
      final precio = _getEspecialidadPrecio(especialidad) *
          _getDiaHoraFactor(diaSemana, hour) *
          _getCiudadComunaFactor(ciudad, comuna);
      return precio;
    } catch (e) {
      return double.infinity;
    }
  }

  int getMaxPrice(
      String especialidad, int weekDay, String comuna, String ciudad) {
    try {
      int precio_max = 0;
      for (int hora = inicio_turno; hora <= fin_turno; hora++) {
        final precio = getPrice(especialidad, weekDay, hora, comuna, ciudad);
        if (precio > precio_max) precio_max = precio;
      }
      return precio_max;
    } catch (e) {
      return double.infinity.toInt();
    }
  }

  Future<void> savePlutoRows(String id, List<PlutoRow> rows) async {
    final documentAccessor = DocumentAccessor();
    final mat = Matrix(id: id);

    Map<String, Map<String, dynamic>> map = {};
    int index = 0;
    rows.forEach((row) {
      map.addEntries([MapEntry(index.toString(), {})]);
      row.cells.forEach((key, value) {
        map[index.toString()]!.addEntries([MapEntry(key, value.value)]);
      });
      index += 1;
    });

    mat.matrix = map;
    await documentAccessor.save(mat);
  }

  Future existMatrix(String uid) async {
    try {
      final path = Document.path<Matrix>();
      final snapShot = await firestoreInstance.collection(path).doc(uid).get();
      return snapShot.exists;
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future<List<PlutoRow>?> loadPlutoRows(String id) async {
    final documentAccessor = DocumentAccessor();
    final mat = await documentAccessor.load<Matrix>(Matrix(id: id));

    List<PlutoRow> rows = [];
    mat!.matrix!.forEach((stringIndex, value) {
      Map<String, dynamic> rowMap = Map<String, dynamic>.from(value);
      Map<String, PlutoCell> cells = Map<String, PlutoCell>();
      rowMap.forEach((key, value) {
        cells[key] = PlutoCell(value: value);
      });
      rows.add(PlutoRow(cells: cells));
    });

    return rows;
  }

  List<PlutoRow>? getPlutoRows(Matrix mat) {
    List<PlutoRow> rows = [];
    mat.matrix!.forEach((stringIndex, value) {
      Map<String, dynamic> rowMap = Map<String, dynamic>.from(value);
      Map<String, PlutoCell> cells = Map<String, PlutoCell>();
      rowMap.forEach((key, value) {
        cells[key] = PlutoCell(value: value);
      });
      rows.add(PlutoRow(cells: cells));
    });

    return rows;
  }

  void _createInitialMatrixDayHour() {
    _day_hour_rows = [];
    for (int hora = inicio_turno; hora <= fin_turno; hora++) {
      Map<String, PlutoCell> cells = Map<String, PlutoCell>();
      cells["hora"] = PlutoCell(value: hora);
      for (int dia = 1; dia <= 7; dia++)
        cells[dia.toString()] = PlutoCell(value: 1.0);
      _day_hour_rows!.add(PlutoRow(cells: cells));
    }
  }

  void _createInitialMatrixCityComuna() {
    _city_comuna_rows = [];
  }

  void _createInitialMatrixPrice({double value = 1000.0}) {
    _price_rows = [];
    _specializationToDoctorNameTranslation.values.forEach((element) {
      _price_rows!.add(PlutoRow(cells: {
        'speciality': PlutoCell(value: element),
        'price': PlutoCell(value: value)
      }));
    });
  }
}
