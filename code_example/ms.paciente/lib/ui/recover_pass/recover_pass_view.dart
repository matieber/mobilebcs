import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mercadosalud/ui/shared/styles.dart';
import 'package:mercadosalud/ui/shared/ui_helpers.dart';

import 'recover_pass_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class RecoverPassView extends StatelessWidget {
  RecoverPassView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RecoverPassViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(LocaleKeys.UI_RecoverPassView_bienvenida).tr(),
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
                          LocaleKeys.UI_RecoverPassView_instrucciones,
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
                          //onChanged: _onChanged,
                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.email(context),
                          ]),
                          //keyboardType: TextInputType.emailAddress,
                        ),
                      ],
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
                                LocaleKeys.UI_RecoverPassView_recover,
                                style: bigButton,
                              ).tr(),
                      ),
                    ),
                  ],
                ),
              ))),
      viewModelBuilder: () => RecoverPassViewModel(),
    );
  }
}
