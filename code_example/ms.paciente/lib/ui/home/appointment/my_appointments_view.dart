import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/ui/favourite/favourite_view_model.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'appointment_detail_viewmodel.dart';
import 'my_appointments_viewmodel.dart';
import 'package:mercadosalud/ui/home/drawer/drawer_view.dart';

class MyAppointmentView extends StatelessWidget {
  final _logger = getLogger('MyAppointmentsView');

  MyAppointmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyAppointmentsViewModel>.reactive(
      viewModelBuilder: () => MyAppointmentsViewModel(false),
      builder: (context, model, child) => Scaffold(
        drawer: MainDrawerView(),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Mis Turnos"),
        ),
        body: model.data == null || !model.dataReady
            ? Center(child: CircularProgressIndicator())
            : model.data!.length > 0
                ? ListView.separated(
                    itemCount: model.data!.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {},
                      child: Dismissible(
                          key: Key(model.data![index].id),
                          direction: model.isAppointmentDue(model.data![index])
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return model
                                .startCancellingAppointment(model.data![index]);
                          },
                          background: Container(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child: Text(
                                  LocaleKeys
                                          .UI_MyAppointmentsView_desplazar_para_cancelar
                                      .tr(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Poppins",
                                      color: Colors.white),
                                ).tr(),
                              ),
                              decoration:
                                  BoxDecoration(color: Colors.redAccent)),
                          child: buildAppointmentCard(
                              model.data![index], model.favouritesModel)),
                    ),
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(color: Colors.black26);
                    },
                  )
                : Center(
                    child: Text(
                    LocaleKeys.UI_MyAppointmentsView_sin_reservas.tr(),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )),
      ),
    );
  }

  buildAppointmentCard(
      Assignment assignment, FavouriteViewModel favoriteModel) {
    _logger.d('building appointment card: ${assignment.turno_id}');
    return ViewModelBuilder<AppointmentDetailViewModel>.reactive(
      builder: (context, model, child) => model.isBusy
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: 160,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                    children: [
                  ListTile(
                    title: Wrap(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 0.0, right: 8.0, bottom: 0.0),
                          child: Text(
                            'Con: ${model.doctor?.titulo_cortesia ?? ""} ${model.doctor?.fullNameCap ?? ""}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis, softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                      )
                    ]),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(
                            left: 00.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Text(
                          "${model.doctor!.especialidad} / Precio: \$${model.assignment!.precio}",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        )),
                    isThreeLine: false,
                    trailing: ViewModelBuilder<FavouriteViewModel>.reactive(
                      disposeViewModel: false,
                      builder: (context, favmodel, child) => favmodel.isBusy
                          ? Center(child: CircularProgressIndicator())
                          : IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: favmodel.isFavourite(model.doctor!.id)
                                    ? Colors.redAccent
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                favmodel.setUnsetFavourite(model.doctor!);
                              }),
                      viewModelBuilder: () =>
                          favoriteModel, //FavouriteViewModel(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 0.0, right: 8.0, bottom: 0.0),
                      child: Text(
                        'Para: ${model.assignment!.paciente_fullName}',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 18),
                      ),
                    ),
                  ),
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Icon(Icons.location_on)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Text(
                          '${model.doctor!.address!.street} '
                          '${model.doctor!.address!.number}, '
                          '${model.doctor!.address!.cityCap}',
                          style: TextStyle(
                              fontStyle: FontStyle.normal, fontSize: 18),
                        ),
                      ),
                    )
                  ]),
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Icon(Icons.calendar_today_rounded)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${model.appointment!.fecha!.toDate().day}-"
                        "${model.appointment!.fecha!.toDate().month}-"
                        "${model.appointment!.fecha!.toDate().year}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Icon(Icons.schedule)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${model.appointment!.hora_min_inicio} hs.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ]),
                ]),
              )),
      viewModelBuilder: () => AppointmentDetailViewModel(assignment),
    );
  }
}
