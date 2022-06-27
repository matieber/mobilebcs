import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/ui/shared/styles.dart';
import 'package:mercadosalud/ui/shared/ui_helpers.dart';

import 'package:auth_buttons/auth_buttons.dart';

import 'login_viewmodel.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(LocaleKeys.UI_LoginView_bienvenida).tr(),
          ),
          body: Padding(
              padding: largeFieldPadding,
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: screenWidthPercentage(context, percentage: 1.0),
                        child: Text(
                          LocaleKeys.UI_LoginView_instrucciones,
                          style: Theme.of(context).textTheme.headline6,
                        ).tr(),
                      ),
                    ),
                    verticalSpaceRegular,
                    Column(
                      children: [
                        FormBuilderTextField(
                          name: 'email',
                          style: Theme.of(context).textTheme.bodyText2,

                          decoration: InputDecoration(
                            labelStyle: Theme.of(context).textTheme.subtitle1,
                            labelText: LocaleKeys.UI_LoginView_email.tr(),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.email(context),
                          ]),
                        ),
                        verticalSpaceSmall,
                        FormBuilderTextField(
                          name: 'password',
                          style: Theme.of(context).textTheme.bodyText2,

                          decoration: InputDecoration(
                              labelStyle: Theme.of(context).textTheme.subtitle1,
                              labelText: LocaleKeys.UI_LoginView_clave.tr(),
                              //prefixIcon: Icon(Icons.security),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: model.showPassword()
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    model.tooglePassword();
                                  })),
                          obscureText: !model.showPassword(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.minLength(context, 6),
                          ]),
                        ),
                      ],
                    ),
                    verticalSpaceRegular,
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                          onTap: () => model.navigateTorecoverPass(),
                          child: Text(
                            LocaleKeys.UI_LoginView_olvidoclave,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Theme.of(context).accentColor),
                          ).tr()),
                    ),
                    verticalSpaceRegular,
                    GestureDetector(
                      onTap: () => //onSubmit(model), //
                          model.submitIfValid(_formKey.currentState!),
                      child: Container(
                        width: double.infinity,
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
                                LocaleKeys.UI_LoginView_ingresar,
                                style: bigButton,
                              ).tr(),
                      ),
                    ),
                    verticalSpaceRegular,
                    GestureDetector(
                      onTap: model.navigateToCreateAccount,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.UI_LoginView_notienecuenta,
                            style: Theme.of(context).textTheme.headline6,
                          ).tr(),
                          horizontalSpaceTiny,
                          Text(LocaleKeys.UI_LoginView_crearcuenta,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Theme.of(context).accentColor))
                              .tr()
                        ],
                      ),
                    ),
                    verticalSpaceRegular,
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.UI_LoginView_o,
                          style: Theme.of(context).textTheme.headline6,
                        ).tr()),
                    verticalSpaceRegular,
                    GoogleAuthButton(
                      onPressed: model.useGoogleAuthentication,
                      style: AuthButtonStyle(
                          buttonColor: Theme.of(context).accentColor,
                          iconSize: 24,
                          iconBackground: Colors.white,
                          height: 50,
                          iconType: AuthIconType.secondary,
                          textStyle: TextStyle(color: Colors.white)),
                      text: 'CONTINUAR CON GOOGLE',
                    ),
                  ],
                ),
              ))),
      viewModelBuilder: () => LoginViewModel(),
    );
  }
}
