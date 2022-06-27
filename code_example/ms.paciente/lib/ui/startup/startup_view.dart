import 'package:mercadosalud/ui/startup/startup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      createNewModelOnInsert: true,
      onModelReady: (model) =>
          SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        model.runStartUpLogic();
      }),
      builder: (context, model, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                //width: 300,
                //height: 100,
                child: Image.asset('assets/images/ms.splash.png'),
              ),
              verticalSpaceRegular,
              model.isBusy
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : verticalSpaceRegular,
              verticalSpaceRegular,
              !model.isBusy && !model.isEnabled
                  ? getStatus(context, model)
                  : verticalSpaceTiny,
              //getButton(context, model, child),
              //verticalSpaceRegular,
            ],
          ),
        ),
      ),
      viewModelBuilder: () => StartUpViewModel(),
    );
  }

  getStatus(context, model) {
    if (model.hasUser) {
      return Align(
        alignment: Alignment.topCenter,
        child: Text(
          LocaleKeys.UI_StartUpView_desactivado.tr(),
          style: ktsMediumRedBodyText,
        ),
      );
    } else
      return verticalSpaceRegular;
  }

  getButton(context, model, child) {
    if (model.hasUser)
      return Container(
        margin: EdgeInsets.all(25),
        child: FlatButton(
          child: Text(
            'Continuar',
            style: TextStyle(fontSize: 20.0),
          ),
          color: Colors.cyan,
          textColor: Colors.black,
          onPressed: () {
            model.runStartUpLogic();
          },
        ),
      );
    else
      return verticalSpaceRegular;
  }
}
