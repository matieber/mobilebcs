import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
//import 'package:mercadosalud/ui/shared/styles.dart';
//import 'package:mercadosalud/ui/shared/ui_helpers.dart';
import 'package:mercadosaludlib/mercadosalud.dart';

import 'address_selection_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';
import 'package:flutter/scheduler.dart';

import 'package:mercadosalud/app/app.logger.dart';
import './form_builder_phone_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:mercadosalud/app/app.locator.dart';

final sexos = [
  FormBuilderFieldOption(value: 'Mujer', child: Text('Mujer')),
  FormBuilderFieldOption(value: 'Hombre', child: Text('Hombre')),
  FormBuilderFieldOption(value: 'Otro', child: Text('Otro'))
];

class AddressSelectionView extends StatelessWidget {
  AddressSelectionView({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormBuilderState>();
  final _logger = getLogger('AddressSelectionView');

  @override
  Widget build(BuildContext context) {
    MSWidgetFactory ms_fact = MSWidgetFactory();
    return ViewModelBuilder<AddressSelectionViewModel>.reactive(
      onModelReady: (model) =>
          SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        _logger.d("ready");
        model.runStartUpLogic(_formKey.currentState!);
        //_logger.d("phone" + _formKey.currentState!.fields['phone']?.value);
      }),
      builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(LocaleKeys.UI_AddressSelectionView_bienvenida).tr(),
          ),
          body: SafeArea(
              minimum: largeFieldPadding,
              child: FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  //child: ListView(
                  //children: [
                  //cambie listView por SingleChildScrollView ya que sino se olvidaba los valores de los campos!!!
                  child: SingleChildScrollView(
                    child: new Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width:
                                screenWidthPercentage(context, percentage: 1.0),
                            child: Text(
                              LocaleKeys.UI_AddressSelectionView_instrucciones,
                              style: Theme.of(context).textTheme.headline6,
                            ).tr(),
                          ),
                        ),
                        verticalSpaceRegular,
                        _getfullName(context, model),
                        verticalSpaceRegular,
                        //_dni_selfie_celular(context, model),
                        _getRow(
                            _getSelfieWidget(context, model),
                            _getColumn(_getPhoneField(context, model),
                                _getDNIField(context, model)),
                            flex2: 3),
                        verticalSpaceRegular,
                        _getSexo(context),
                        verticalSpaceRegular,
                        _getRow(
                            _getColumn(_getStreetField(context, model),
                                _getCityField(context, model)),
                            _getColumn(_getStreetNumField(context, model),
                                _getStreetFloorField(context, model)),
                            flex1: 2),
                        verticalSpaceRegular,

                        verticalSpaceRegular,
                        //_getPhoneField(context, model),
                        verticalSpaceRegular,
                        //_getDNIField(context, model),
                        verticalSpaceRegular,
                        //_getSelfieWidget(context, model),

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
                                    LocaleKeys.UI_AddressSelectionView_guardar,
                                    style: bigButton,
                                  ).tr(),
                          ),
                        ),
                      ],
                    ),
                  )))),
      viewModelBuilder: () => AddressSelectionViewModel(),
    );
  }

  Widget _getfullName(context, model) {
    return FormBuilderTextField(
        name: 'fullName',
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_CreateAccountView_name.tr()),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(context),
        ]));
  }

  Widget _getDNIField(context, model) {
    return FormBuilderTextField(
      name: 'dni',
      style: Theme.of(context).textTheme.bodyText2,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_AddressSelectionView_identidad.tr(),
      ),
      //onChanged: _onChanged,
      // valueTransformer: (text) => num.tryParse(text),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.numeric(context),
        FormBuilderValidators.max(context, 100000000),
        FormBuilderValidators.min(context, 1),
      ]),
      keyboardType: TextInputType.number,
    );
  }

  Widget _getSexo(context) {
    final focus_node = FocusNode();
    return Focus(
        canRequestFocus: true,
        focusNode: focus_node,
        autofocus: true,
        child: FormBuilderChoiceChip<String>(
          focusNode: focus_node,
          name: 'sex',
          selectedColor: kcPrimaryColor,
          labelStyle: TextStyle(fontSize: 10.0),
          decoration: InputDecoration(
            //border: InputBorder.none,
            //focusedBorder: InputBorder.none,
            //enabledBorder: InputBorder.none,
            //errorBorder: InputBorder.none,
            //disabledBorder: InputBorder.none,

            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_AddressSelectionView_sexo.tr(),
          ),
          options: sexos,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(context),
          ]),
        ));
  }

  Widget _getStreetField(context, model) {
    return FormBuilderTextField(
      name: 'street',
      style: Theme.of(context).textTheme.bodyText2,

      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_AddressSelectionView_calle.tr(),
      ),
      //onChanged: _onChanged,
      // valueTransformer: (text) => num.tryParse(text),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
      ]),
      //keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _getStreetNumField(context, model) {
    return FormBuilderTextField(
      name: 'number',
      style: Theme.of(context).textTheme.bodyText2,

      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_AddressSelectionView_numero.tr(),
      ),
      //onChanged: _onChanged,
      // valueTransformer: (text) => num.tryParse(text),
      keyboardType: TextInputType.number,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.numeric(context),
      ]),
      //keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _getStreetFloorField(context, model) {
    return FormBuilderTextField(
      name: 'floor_dep',
      style: Theme.of(context).textTheme.bodyText2,

      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_AddressSelectionView_piso_depto.tr(),
      ),
      //onChanged: _onChanged,
      // valueTransformer: (text) => num.tryParse(text),
      validator: FormBuilderValidators.compose([
        //FormBuilderValidators.required(context),
      ]),
      //keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _getCityField(context, model) {
    return FormBuilderTextField(
        style: Theme.of(context).textTheme.bodyText2,
        name: 'city',
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.subtitle1,
          labelText: LocaleKeys.UI_AddressSelectionView_ciudad.tr(),
        ),
        //onChanged: _onChanged,
        // valueTransformer: (text) => num.tryParse(text),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(context),
        ]));
  }

  Widget _getPhoneField(context, model) {
    return FormBuilderPhoneField(
      name: 'phone',
      style: Theme.of(context).textTheme.bodyText2,
      initialValue: model.phone,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.subtitle1,
        labelText: LocaleKeys.UI_AddressSelectionView_telefono.tr(),
        //hintText: 'Busqueda!!!',
      ),
      countryFilterByIsoCode: ['AR', 'CL', 'PE', 'CO', 'MX', 'US', 'PY', 'UY'],
      // onChanged: _onChanged,
      priorityListByIsoCode: ['AR', 'CL', 'PE', 'CO', 'MX', 'US', 'PY', 'UY'],
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.numeric(context),
        FormBuilderValidators.required(context),
      ]),
    );
  }

  Widget _getSelfieWidget(context, model) {
    return FormBuilderImagePicker(
        name: 'selfie',
        initialValue: model.selfieUrl != null ? [model.selfieUrl] : [],
        onSaved: (value) {
          print('location saved: $value');
        },
        decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_AddressSelectionView_foto.tr()),
        maxImages: 1,
        previewWidth: MediaQuery.of(context).size.width * 0.2,
        validator: FormBuilderValidators.compose([
          (val) {
            if (val!.isEmpty && model.selfieUrl == null)
              return LocaleKeys.UI_DoctorSettingsView_tituloError.tr();

            return null;
          }
        ]));
  }

  Widget _getColumn(Widget w1, Widget w2) {
    return Container(
        child: Column(children: [
      w1,
      verticalSpaceSmall,
      w2,
    ]));
  }

  Widget _getRow(Widget w1, Widget w2, {int flex1 = 1, int flex2 = 1}) {
    return Container(
        child: Row(children: [
      Expanded(flex: flex1, child: w1),
      horizontalSpaceSmall,
      Expanded(flex: flex2, child: w2)
    ]));
  }
}
