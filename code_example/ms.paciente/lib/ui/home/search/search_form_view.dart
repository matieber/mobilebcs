import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mercadosalud/ui/home/drawer/drawer_view.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

class SearchFormView extends StatefulWidget {
  SearchFormView({Key? key}) : super(key: key);

  @override
  _SearchFormViewState createState() => _SearchFormViewState();
  final _formKey = GlobalKey<FormBuilderState>();
}

class _SearchFormViewState extends State<SearchFormView> {
  final _navigationService = locator<NavigationService>();

  final _logger = getLogger('SearchFormView');

  late LatLng _initialPosition;

  Location _location = Location();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late GoogleMapController _mapController;

  StateSetter? _setStateDialog;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  _initLocation() async {
    var _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) throw 'GPS service is disabled';
    }
    var _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted)
        throw 'No GPS permissions';
    }

    _location.onLocationChanged.listen((LocationData event) async {
      _initialPosition = LatLng(event.latitude!, event.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchFormViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
          drawer: MainDrawerView(),
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(LocaleKeys.UI_SearchFormView_titulo).tr(),
          ),
          body: SafeArea(
              minimum: largeFieldPadding,
              child: SingleChildScrollView(
                  child: FormBuilder(
                key: widget._formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    verticalSpaceMedium,
                    buildSpecializationFormBuilderDropdownSelector(model),
                    verticalSpaceMedium,
                    buildRegionFormBuilderDropdown(model),
                    verticalSpaceMedium,
                    buildRegionFormBuilderSlider(model),
                    verticalSpaceMedium,
                    buildSearchButton(model),
                  ],
                ),
              )))),
      viewModelBuilder: () => SearchFormViewModel(),
    );
  }

  @override
  Widget buildorig(BuildContext context) {
    return Scaffold(
      drawer: MainDrawerView(),
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Encontrá tu turno"),
      ),
      body: Padding(
        padding: largeFieldPadding,
        child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ViewModelBuilder<SearchFormViewModel>.reactive(
            viewModelBuilder: () => SearchFormViewModel(),
            disposeViewModel: false,
            builder: (context, model, child) => model.isBusy
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black)))
                : FormBuilder(
                    key: widget._formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildSpecializationFormBuilderDropdownSelector(model),
                          Container(
                            height: 40,
                          ),
                          Divider(thickness: 1, color: Colors.black38),
                          getColumn(buildRegionFormBuilderDropdown(model),
                              buildRegionFormBuilderSlider(model)),
                          Container(
                            height: 40,
                          ),
                          Divider(thickness: 1, color: Colors.black38),
                          buildSearchButton(model),
                        ]),
                  ),
          ),
        ])),
      ),
    );
  }

  Widget _getEspecialidadesWidget(context, SearchFormViewModel model) {
    final focus_node = FocusNode();

    return //FormBuilderFilterChip<String>(
        Focus(
            canRequestFocus: true,
            focusNode: focus_node,
            autofocus: true,
            child: FormBuilderChoiceChip<String>(
              name: 'especialidad',
              focusNode: focus_node,
              selectedColor: kcPrimaryColor,
              spacing: 0.0,
              labelStyle: TextStyle(fontSize: 8.0),
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.subtitle1,
                labelText: LocaleKeys.UI_DoctorSettingsView_especialidades.tr(),
              ),
              options: model.specializationsList
                  .map<FormBuilderFieldOption<String>>((String value) =>
                      FormBuilderFieldOption<String>(
                          value: value, child: Text("$value")))
                  .toList(),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context),
              ]),
            ));
  }

  buildSpecializationFormBuilderDropdownSelector(SearchFormViewModel model) {
    return FormBuilderDropdown(
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_SearchFormView_especialidad.tr(),
      ),
      name: "selectedSpecialization",
      initialValue: model.selectedSpecialization,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: Theme.of(context).textTheme.bodyText2,
      onChanged: (String? newValue) {
        model.selectedSpecialization = newValue!;
      },
      items: model.specializationsList
          .map<DropdownMenuItem<String>>((String value) =>
              DropdownMenuItem<String>(value: value, child: Text("$value")))
          .toList(),
    );
  }

  buildRegionFormBuilderDropdown(SearchFormViewModel model) {
    final focus_node = FocusNode();

    return getRowExpanded(Focus(
        canRequestFocus: true,
        focusNode: focus_node, //This is the important part
        autofocus: true,
        child: FormBuilderChoiceChip<String>(
          //runSpacing: 130,
          spacing: 20.0,
          focusNode: focus_node,

          runAlignment: WrapAlignment.center,
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
          decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_SearchFormView_zona.tr(),
          ),
          name: "regionAround",

          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(context),
          ]),

          initialValue: model.selectedRegionOption,
          elevation: 16,
          onChanged: (String? newValue) {
            setState(() {
              model.selectedRegionOption = newValue!;
              if (model.selectedRegionOption == "Mi ubicación") {
                markers.clear();
                _getPosition().then((value) => _initialPosition = value);
                _logger.d("Mi ubicación : " + _initialPosition.toString());
                model.searchLocation = _initialPosition;
              } else if (model.selectedRegionOption == "Indicar en el mapa") {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _showZoneSelectionMap(model);
                  },
                );
              } else if (model.selectedRegionOption == "Mi domicilio") {
                model.loadAddressGeoReference();
                LatLng _addressPosition = LatLng(
                    model.geopoints.values.elementAt(1).latitude,
                    model.geopoints.values.elementAt(1).longitude);
                model.searchLocation = _addressPosition;
                _addAddressMarker(_addressPosition);
              }
            });
          },
          options: model.regionOptionsList
              .map<FormBuilderFieldOption<String>>((String value) =>
                  FormBuilderFieldOption<String>(
                      value: value, child: Text("$value")))
              .toList(),
        )));
  }

  buildRegionFormBuilderSlider(SearchFormViewModel model) {
    return FormBuilderSlider(
        name: 'slider',
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.min(context, 1),
        ]),
        min: 1,
        max: 20,
        initialValue: model.radius,
        divisions: 19,
        activeColor: Colors.red,
        inactiveColor: Colors.pink[100],
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.subtitle1,
          labelText: LocaleKeys.UI_SearchFormView_zona_amplia.tr(),
        ),
        onChanged: (double? newRadius) {
          model.radius = newRadius!;
        });
  }

  String format(double radius) {
    return radius.floor().toString();
  }

  _showZoneSelectionMap(SearchFormViewModel model) {
    return AlertDialog(
        content: StatefulBuilder(// You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
      _setStateDialog = setState;

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.70,
        child: Column(children: [
          Container(
            height: 15,
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                if (_mapController == null) {
                  _mapController = controller;
                }
              },
              markers: Set<Marker>.of(markers.values),
              compassEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              rotateGesturesEnabled: true,
              onLongPress: _addMarker,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 11.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              SizedBox.fromSize(
                child: Text(
                    "Mantenga presionado un segundo sobre la zona del mapa adonde desea orientar la búsqueda y luego presione Ok",
                    style: TextStyle(fontSize: 12)),
                //size: Size(215, 95),
              ),
              ElevatedButton(
                  child: Text("Ok"),
                  onPressed: () {
                    model.searchLocation = LatLng(
                        markers.values.first.position.latitude,
                        markers.values.first.position.longitude);
                    Navigator.of(context).pop();
                  })
            ]),
          ),
        ]),
      );
    }));
  }

  Future<LatLng> _getPosition() async {
    final data = await Location().getLocation();
    return LatLng(data.latitude!, data.longitude!);
  }

  _addMarker(LatLng tappedPoint) {
    markers.clear();
    final id = MarkerId(
        tappedPoint.latitude.toString() + tappedPoint.longitude.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(tappedPoint.latitude, tappedPoint.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    //se usa el setState de Dialog para actualizar
    _setStateDialog!(() {
      _logger.d("set state marker dialog!");
      markers[id] = _marker;
    });
  }

  _addAddressMarker(LatLng tappedPoint) {
    markers.clear();

    final id = MarkerId(
        tappedPoint.latitude.toString() + tappedPoint.longitude.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(tappedPoint.latitude, tappedPoint.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    //se usa el setState de Dialog para actualizar
    setState(() {
      markers[id] = _marker;
    });
  }

  Widget buildSearchButton(SearchFormViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              if (widget._formKey.currentState!.saveAndValidate()) {
                _logger.d("Valid data form");

                if (model.searchLocation == null) {
                  _getPosition().then((value) {
                    model.searchLocation = value;
                    _navigationService.navigateTo(Routes.searchResultsTabView,
                        arguments:
                            SearchResultsTabViewArguments(searchModel: model));
                  });
                } else {
                  _navigationService.navigateTo(Routes.searchResultsTabView,
                      arguments:
                          SearchResultsTabViewArguments(searchModel: model));
                }
              }
            },
            child: const Text('Buscar'),
          ),
        ),
      ],
    );
  }
}
