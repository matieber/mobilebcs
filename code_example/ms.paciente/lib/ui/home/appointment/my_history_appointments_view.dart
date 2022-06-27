import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:mercadosalud/app/app.logger.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/services/authentication_service.dart';
import 'package:mercadosalud/ui/favourite/favourite_view_model.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'appointment_detail_viewmodel.dart';
import 'my_appointments_viewmodel.dart';
import 'package:mercadosalud/ui/home/drawer/drawer_view.dart';

class MyHistoryAppointmentView extends StatelessWidget {
  final _logger = getLogger('MyHistoryAppointmentView');
  final _navigationService = locator<NavigationService>();

  MyHistoryAppointmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyAppointmentsViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        drawer: MainDrawerView(),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Mis Turnos Pasados"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(160.0),
            child: _buildUserInfo(),
          ),
        ),
        body: model.data == null || !model.dataReady
            ? Center(child: CircularProgressIndicator())
            : model.data!.length > 0
                ? ListView.separated(
                    itemCount: model.data!.length,
                    itemBuilder: (context, index) => GestureDetector(
                        onTap: () {},
                        child: buildAppointmentCard(
                            model.data![index], model.favouritesModel)),
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(color: Colors.black26);
                    },
                  )
                : Center(
                    child: Text(
                    LocaleKeys.UI_MyAppointmentsView_sin_historicos.tr(),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )),
      ),
      viewModelBuilder: () => MyAppointmentsViewModel(true),
    );
  }

  Widget _buildUserInfo() {
    final _firebaseAuthenticationService = locator<AuthenticationService>();
    Paciente? user = _firebaseAuthenticationService.currentUser;
    return Column(
      children: [
        Avatar(
          photoUrl: user?.selfie?.url,
          radius: 50,
          borderColor: Colors.black54,
          borderWidth: 2.0,
        ),
        const SizedBox(height: 8),
        if (user!.fullNameCap != null)
          //if (model.user.email != null)
          Text(
            user.fullNameCap!,
            //model.user.email,
            style: const TextStyle(color: Colors.white),
          ),
        const SizedBox(height: 8),
      ],
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
                child: Column(children: [
                  ListTile(
                    title: Wrap(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 0.0, right: 8.0, bottom: 0.0),
                          child: Text(
                            'Con: ${model.doctor!.titulo_cortesia} ${model.doctor!.fullNameCap}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ]),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(
                            left: 00.0, top: 0.0, right: 8.0, bottom: 0.0),
                        child: Text(
                          "${model.doctor!.especialidad}",
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
                            favoriteModel //FavouriteViewModel(),
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
