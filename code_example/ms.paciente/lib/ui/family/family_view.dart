//import 'package:mercadosalud/ui/shared/ui_helpers.dart';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:mercadosalud/app/app.locator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import './family_view_model.dart';
import './person_item.dart';
import 'package:flutter/scheduler.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class FamiltyView extends StatelessWidget {
  const FamiltyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FamiltyViewModel>.reactive(
        onModelReady: (model) =>
            SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
              model.runStartUpLogic();
            }),
        viewModelBuilder: () => FamiltyViewModel(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(LocaleKeys.UI_FamiltyView_bienvenida).tr(),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).accentColor,
                child: !model.isBusy
                    ? Icon(Icons.add)
                    : CircularProgressIndicator(),
                onPressed: model.navigateToCreateView,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    verticalSpaceMedium,
                    Expanded(
                        child: model.persons != null
                            ? ListView.builder(
                                key: PageStorageKey(
                                    'storage-key'), //recuerda ubicacion en la pantalla
                                itemCount: model.persons!.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () => model.editPerson(index),
                                  child: PersonItem(
                                    person: model.persons![index],
                                    onDeleteItem: () =>
                                        model.deletePerson(index),
                                  ),
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).primaryColor),
                                ),
                              )),
                    GestureDetector(
                      onTap: () => //onSubmit(model), //
                          model.submitIfValid(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: model.isBusy
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )
                            : Text(
                                LocaleKeys.UI_AddressSelectionView_guardar,
                                style: bigButton,
                              ).tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
