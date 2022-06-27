//import 'package:mercadosalud/ui/shared/ui_helpers.dart';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import './favourite_view_model.dart';
import './doctor_item.dart';
import 'package:flutter/scheduler.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class FavouriteView extends StatelessWidget {
  const FavouriteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FavouriteViewModel>.reactive(
        /*onModelReady: (model) =>
            SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
              model.runStartUpLogic();
            }),*/
        viewModelBuilder: () => FavouriteViewModel(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(LocaleKeys.UI_FavouriteView_bienvenida.tr()),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    verticalSpaceMedium,
                    Expanded(
                        child: model.doctors != null
                            ? ListView.builder(
                                key: PageStorageKey(
                                    'storage-key'), //recuerda ubicacion en la pantalla
                                itemCount: model.doctors!.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () => model.navigateToDoctorCalendar(index),
                                  child: DoctorItem(
                                    doctor: model.doctors![index],
                                    onDeleteItem: () =>
                                        model.deleteDoctor(index),
                                  ),
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).primaryColor),
                                ),
                              )
                    ),
                  ],
                ),
              ),
            ));
  }
}
