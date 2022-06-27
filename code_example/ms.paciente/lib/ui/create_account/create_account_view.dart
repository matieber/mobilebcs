import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/ui/shared/styles.dart';
import 'package:mercadosalud/ui/shared/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

import 'create_account_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateAccountView extends StatelessWidget {
  CreateAccountView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateAccountViewModel>.reactive(
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
                          LocaleKeys.UI_CreateAccountView_instrucciones.tr(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
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
                            labelText:
                                LocaleKeys.UI_CreateAccountView_email.tr(),
                          ),
                          //onChanged: _onChanged,
                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.email(context),
                          ]),
                          //keyboardType: TextInputType.emailAddress,
                        ),
                        verticalSpaceSmall,
                        FormBuilderTextField(
                          name: 'password',
                          onChanged: (value) => model.notifyListeners(),

                          style: Theme.of(context).textTheme.bodyText2,

                          decoration: InputDecoration(
                              labelStyle: Theme.of(context).textTheme.subtitle1,
                              labelText:
                                  LocaleKeys.UI_CreateAccountView_clave.tr(),
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
                          //obscureText: true,
                          obscureText: !model.showPassword(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.minLength(context, 6),
                          ]),
                        ),
                        verticalSpaceSmall,
                        FormBuilderTextField(
                            name: 'confirm_password',
                            onChanged: (value) => model.notifyListeners(),
                            style: Theme.of(context).textTheme.bodyText2,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelStyle: Theme.of(context).textTheme.subtitle1,
                              labelText: LocaleKeys
                                  .UI_CreateAccountView_claveConf.tr(),
                              suffixIcon: getIcon(),
                            ),
                            obscureText: !model.showPassword(),
                            validator: FormBuilderValidators.compose([
                              /*FormBuilderValidators.equal(
                        context,
                        _formKey.currentState != null
                            ? _formKey.currentState.fields['password'].value
                            : null),*/
                              (val) {
                                if (val !=
                                    _formKey.currentState!.fields['password']!
                                        .value) {
                                  return LocaleKeys
                                          .UI_CreateAccountView_claveNoCoincide
                                      .tr();
                                }
                                return null;
                              }
                            ]))
                      ],
                    ),
                    verticalSpaceRegular,
                    verticalSpaceRegular,
                    /*if (validationMessage != null)
              Text(
                validationMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: kBodyTextSize,
                ),
              ),
            if (validationMessage != null) verticalSpaceRegular,*/
                    GestureDetector(
                      onTap: () => model.submitIfValid(_formKey.currentState!),
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
                                LocaleKeys.UI_CreateAccountView_ingresar.tr(),
                                style: bigButton,
                              ),
                      ),
                    ),
                    verticalSpaceRegular,
                    Text(
                      LocaleKeys.UI_CreateAccountView_condiciones_aceptadas
                          .tr(),
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),

                    verticalSpaceRegular,

                _buildTyCText(context)]
                ),
              ))),
      viewModelBuilder: () => CreateAccountViewModel(),
    );
  }

  RichText _buildTyCText(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Acceda a los términos y condiciones ',
        style: Theme.of(context).textTheme.headline6,
        children: <TextSpan>[
          TextSpan(
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              text: 'aquí',
              recognizer: TapGestureRecognizer()
                ..onTap = ()
                async {
                  var url = "https://www.pricehealth.io/";
                  launch(url);
                }
          ),
        ],
      ),
    );
  }

  Icon getIcon() {
    if (_formKey.currentState == null)
      return const Icon(Icons.error, color: Colors.red);
    if (_formKey.currentState != null &&
        !_formKey.currentState!.fields['confirm_password']!.isValid)
      return const Icon(Icons.error, color: Colors.red);
    return const Icon(Icons.check, color: Colors.green);
  }
}
