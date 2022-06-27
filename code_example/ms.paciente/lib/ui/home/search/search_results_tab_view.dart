import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/app/app.router.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:mercadosalud/ui/home/search/search_form_viewmodel.dart';
import 'package:mercadosalud/ui/home/search/search_results_tab_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'my_marker.dart';

Future<Uint8List> _myPainterToBitmap(String label) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  MyPainter myPainter = MyPainter(label);
  myPainter.paint(canvas, Size(200, 100));
  final ui.Image image = await recorder.endRecording().toImage(200, 100);
  final ByteData byteData =
      (await image.toByteData(format: ui.ImageByteFormat.png))!;
  return byteData.buffer.asUint8List();
}

class SearchResultsTabView extends StatefulWidget {
  SearchFormViewModel searchModel;

  SearchResultsTabView({Key? key, required this.searchModel}) {}

  @override
  _SearchResultsTabViewState createState() => _SearchResultsTabViewState();
}

class _SearchResultsTabViewState extends State<SearchResultsTabView> {
  final _logger = getLogger('_SearchResultsTabViewState');
  final _navigationService = locator<NavigationService>();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late GoogleMapController _myController;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchResultsTabViewModel>.reactive(
      viewModelBuilder: () =>
          SearchResultsTabViewModel(searchCriteria: widget.searchModel),
      disposeViewModel: false,
      builder: (context, SearchResultsTabViewModel resultsData, child) =>
          DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Servicios Médicos"),
            bottom: TabBar(
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 5.0,
              labelColor: Colors.white,
              labelPadding: EdgeInsets.only(top: 10.0),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  text: 'Mapa',
                  icon: Icon(
                    Icons.map,
                    color: Colors.white,
                  ),
                  iconMargin: EdgeInsets.only(bottom: 10.0),
                ),
                Tab(
                  text: 'Lista',
                  icon: Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                  iconMargin: EdgeInsets.only(bottom: 10.0),
                ),
              ],
            ),
          ),
          body: !resultsData.dataReady
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _myController = controller;

                        _addMarker(widget.searchModel.searchLocation!);
                        resultsData.stream.listen((doctorsList) {
                          if (doctorsList.isEmpty) {
                            _logger.d(
                                "No se encontraron Especialistas disponibles. Mostrando el más cercano fuera de esa zona");
                            showDialog(
                                context: context,
                                builder: (_) => new AlertDialog(
                                      title: new Text(
                                          "No se encontraron médicos con turnos disponibles"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Ok'),
                                          onPressed: () {
                                            //Navigator.of(context).pop();
                                            _navigationService
                                                .clearStackAndShow(
                                                    Routes.homeView,
                                                    arguments:
                                                        HomeViewArguments(
                                                            focusedTab: 0));
                                          },
                                        )
                                      ],
                                    ));
                            resultsData.stream_AtLeastOne.listen((doctorList2) {
                              resultsData.onData(doctorList2);
                              _updateMarkers(doctorList2);
                            });
                          } else {
                            _updateMarkers(resultsData.data);
                          }
                        });
                      },
                      initialCameraPosition: CameraPosition(
                        target: widget.searchModel.searchLocation!,
                        zoom: 11.0,
                      ),
                      markers: Set<Marker>.of(markers.values),
                      compassEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      rotateGesturesEnabled: true,
                    ),
                    ListView.builder(
                      itemCount: resultsData.data!.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Doctor? doc = resultsData.data![index];
                          _navigationService.navigateTo(Routes.calendarView,
                              arguments: CalendarViewArguments(
                                  doctor: doc,
                                  searchCriteria: widget.searchModel));
                        },
                        child: buildDoctorCard(resultsData.data![index]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _addMarker(LatLng tappedPoint) {
    final id = MarkerId(
        tappedPoint.latitude.toString() + tappedPoint.longitude.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(tappedPoint.latitude, tappedPoint.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
    setState(() {
      _logger.d("Adding marker of patient");
      markers[id] = _marker;
    });
  }

  void _updateMarkers(List<Doctor?>? doctorList) async {
    doctorList!.forEach((Doctor? doctor) async {
      final GeoPoint? point = doctor!.position!.geopoint;
      _logger.d("Updating viewMap marker at: (" +
          point!.latitude.toString() +
          "," +
          point.longitude.toString() +
          ")");
      final id = MarkerId(doctor.id);
      _logger.d("!!!0Doctor ${doctor.id}  minprice: ${doctor.minPrice}");
      final price = Price(doctor).minPrice;
      _logger.d("Doctor $id : precio: $price");
      final bytes = await _myPainterToBitmap('\$$price');
      final _marker = Marker(
        markerId: id,
        position: LatLng(point.latitude, point.longitude),
        anchor: Offset(0.0, 0.5),
        icon: BitmapDescriptor.fromBytes(bytes),
        onTap: () {
          _showDialog(context, doctor);
        },
      );

      setState(() {
        markers[id] = _marker;

        double minx =
            markers.values.map((e) => e.position.latitude).reduce(min);
        double maxx =
            markers.values.map((e) => e.position.latitude).reduce(max);
        double miny =
            markers.values.map((e) => e.position.longitude).reduce(min);
        double maxy =
            markers.values.map((e) => e.position.longitude).reduce(max);

        minx = min(minx, widget.searchModel.searchLocation!.latitude);
        miny = min(miny, widget.searchModel.searchLocation!.longitude);
        maxx = max(maxx, widget.searchModel.searchLocation!.latitude);
        maxy = max(maxy, widget.searchModel.searchLocation!.longitude);

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minx, miny),
          northeast: LatLng(maxx, maxy),
        );
        _myController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20.0));
      });
    });
  }

  _showDialog(BuildContext context, Doctor doctor) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Align(
                  alignment: Alignment.center,
                  child: new Text(
                      "${doctor.titulo_cortesia} ${doctor.fullNameCap}")),
              content: buildMarkerNextAppointmentsInfo(doctor),
              actions: <Widget>[
                TextButton(
                  child: Text('Ver más'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigationService.navigateTo(Routes.calendarView,
                        arguments: CalendarViewArguments(
                            doctor: doctor,
                            searchCriteria: widget.searchModel));
                  },
                )
              ],
            ));
  }

  Widget buildDoctorCard(Doctor? doctorAppointmentPreview) {
    _logger.d('building doctor card: ${doctorAppointmentPreview!.id}');
    _logger.d(
        'recentAppointment.lenght ${doctorAppointmentPreview.recentAppointments!.length}');
    if (doctorAppointmentPreview.recentAppointments != null &&
        doctorAppointmentPreview.recentAppointments!.length > 0) {
      return Container(
          height: 200,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.person, size: 56.0),
                title: Text(
                  doctorAppointmentPreview.titulo_cortesia! +
                      " " +
                      doctorAppointmentPreview.fullNameCap!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  doctorAppointmentPreview.especialidad! + ", ",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios_sharp, size: 40.0),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Turnos por',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 95,
                        ),
                        ViewModelBuilder<Price>.reactive(
                            viewModelBuilder: () =>
                                Price(doctorAppointmentPreview),
                            builder: (context, model, child) => model.isBusy
                                ? Center(child: CircularProgressIndicator())
                                : Text(
                                    'ARS \$${model.minPrice}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ))
                      ],
                    )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, top: 8.0, right: 40.0, bottom: 0.0),
                  child: Text(
                    'Próximos Turnos:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              buildNextAppointmentsWidget(doctorAppointmentPreview)
            ]),
          ));
    } else {
      return Container(
          height: 100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.person, size: 56.0),
                title: Text(
                  doctorAppointmentPreview.titulo_cortesia! +
                      " " +
                      doctorAppointmentPreview.fullNameCap!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  doctorAppointmentPreview.especialidad! + ", ",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.arrow_forward_ios_sharp, size: 40.0),
                //isThreeLine: true,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sin turnos disponibles',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    )),
              ),
            ]),
          ));
    }
  }

  buildNextAppointmentsWidget(Doctor doctor) {
    return Expanded(
      child: ListView.builder(
        itemCount: doctor.recentAppointments!.length == 1 ? 1 : 2,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            Appointment app = doctor.recentAppointments![index];
          },
          child: Align(
            alignment: Alignment.center,
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildNextAppointmentRow(
                      doctor.recentAppointments![index], doctor, 50.0),
                )),
          ),
        ),
      ),
    );
  }

  buildNextAppointmentRow(
      Appointment app, Doctor doctor, double dataPriceSeparator) {
    return [
      Text(
        "${app.fecha!.toDate().day}-"
        "${app.fecha!.toDate().month}-"
        "${app.fecha!.toDate().year}"
        "   ${app.hora_min_inicio} hs.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      SizedBox(
        width: dataPriceSeparator,
      ),
      ViewModelBuilder<Price>.reactive(
        viewModelBuilder: () => Price(doctor),
        builder: (context, model, child) => model.isBusy
            ? Center(child: CircularProgressIndicator())
            : Text(
                'ARS \$${model.getAppointmentPrice(app)}',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
      ),
    ];
  }

  buildMarkerNextAppointmentsInfo(Doctor doctor) {
    if (doctor.recentAppointments != null &&
        doctor.recentAppointments!.length > 0) {
      return Container(
        height: 95,
        width: 100,
        child: Column(children: [
          Row(children: [
            Text("Turnos por ARS ",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
            ViewModelBuilder<Price>.reactive(
                viewModelBuilder: () => Price(doctor),
                builder: (context, model, child) => model.isBusy
                    ? Center(child: CircularProgressIndicator())
                    : Text("\$${model.minPrice}",
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 16)))
          ]),
          SizedBox(height: 10.0),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Próximos Turnos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              )),
          buildNextAppointmentsComponent(doctor)
        ]),
      );
    } else {
      return Text("Sin turnos disponibles",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
    }
  }

  buildNextAppointmentsComponent(Doctor doctor) {
    return Container(
        height: 50,
        child: ListView.builder(
            //to preview only the two first (or only the first) appointments
            itemCount: doctor.recentAppointments!.length > 1 ? 2 : 1,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    //Appointment app = recentAppointments![index];
                  },
                  child: Container(
                      height: 20,
                      child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            children: buildNextAppointmentRow(
                                doctor.recentAppointments![index],
                                doctor,
                                10.0),
                          ))),
                )));
  }
}
