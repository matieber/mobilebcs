import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'create_person_view_model.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class CreatePersonView extends StatelessWidget {
  //final titleController = TextEditingController();
  final PersonaACargo? edittingPost;
  final List<PersonaACargo>? persons;
  CreatePersonView({Key? key, this.edittingPost, this.persons})
      : super(key: key);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePersonViewModel>.reactive(
      viewModelBuilder: () => CreatePersonViewModel(),
      onModelReady: (model) {
        // update the text in the controller
        //titleController.text = edittingPost?.title ?? '';
        //

        if (edittingPost != null)
          model.setEdittingPost(edittingPost!, persons: persons);
      },
      builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(LocaleKeys.UI_FamiltyView_bienvenida_crear).tr(),
          ),
          floatingActionButton: FloatingActionButton(
            child: !model.isBusy
                ? Icon(Icons.add)
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
            onPressed: () {
              if (!model.isBusy) {
                if (_formKey.currentState!.saveAndValidate()) {
                  print('Valid');
                } else {
                  print('Invalid');
                }

                model.submitIfValid(_formKey.currentState!);
              }
            },
            backgroundColor: !model.isBusy
                ? Theme.of(context).primaryColor
                : Colors.grey[600],
          ),
          body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    verticalSpaceLarge,
                    FormBuilderTextField(
                      name: 'fullname',
                      style: Theme.of(context).textTheme.bodyText2,
                      initialValue: edittingPost?.fullName ?? '',
                      decoration: InputDecoration(
                        labelStyle: Theme.of(context).textTheme.subtitle1,
                        labelText: LocaleKeys.UI_FamiltyView_name.tr(),
                      ),
                      //onChanged: _onChanged,
                      // valueTransformer: (text) => num.tryParse(text),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                      ]),
                      //keyboardType: TextInputType.emailAddress,
                    ),
                    verticalSpaceSmall,
                    _dni(context, model),
                    verticalSpaceSmall,
                    _relationship(context, model),
                    verticalSpaceSmall,
                    _getSelfieWidget(context, model),
                  ],
                ),
              ))),
    );
  }

  Widget _relationship(context, model) {
    final focus_node = FocusNode();
    return Focus(
        //fix focusnode
        canRequestFocus: true,
        focusNode: focus_node, //This is the important part
        autofocus: true,
        child: FormBuilderChoiceChip<String>(
          focusNode: focus_node, //Added this line

          name: 'relationship',
          initialValue: edittingPost?.relationship ?? '',
          selectedColor: kcPrimaryColor,
          //runSpacing: -17.0,

          spacing: 0.0,
          //labelPadding: EdgeInsets.fromLTRB(0, -5, 0, -5),
          labelStyle: TextStyle(fontSize: 10.0),
          decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_FamiltyView_relationship.tr(),
          ),
          options: model.relaciones,

          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(context),
          ]),
        ));
  }

  Widget _dni(context, model) {
    return FormBuilderTextField(
      name: 'dni',
      initialValue:
          edittingPost?.dni != null ? edittingPost!.dni.toString() : '',
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

  Widget _getSelfieWidget(context, model) {
    return FormBuilderImagePicker(
        name: 'selfie',
        initialValue: edittingPost?.selfie?.url != null
            ? [edittingPost?.selfie!.url]
            : [],
        decoration: InputDecoration(
            labelStyle: Theme.of(context).textTheme.subtitle1,
            labelText: LocaleKeys.UI_AddressSelectionView_foto.tr()),
        maxImages: 1,
        previewWidth: MediaQuery.of(context).size.width * 0.2,
        validator: FormBuilderValidators.compose([
          (val) {
            if (val == null && edittingPost?.selfie == null)
              return LocaleKeys.UI_DoctorSettingsView_tituloError.tr();

            return null;
          }
        ]));
  }

  Widget _getSelfieWidgetold(context, model) {
    return Row(children: [
      Expanded(
          //flex: 3,
          child: FormBuilderImagePicker(
              name: 'selfie',
              decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.subtitle1,
                  labelText: LocaleKeys.UI_AddressSelectionView_foto.tr()),
              maxImages: 1,
              validator: FormBuilderValidators.compose([
                (val) {
                  if (val == null && edittingPost?.selfie == null)
                    return LocaleKeys.UI_DoctorSettingsView_tituloError.tr();

                  return null;
                }
              ]))),
      Expanded(
          //flex: 3,
          child: edittingPost?.selfie?.url != null
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: CachedNetworkImage(
                    imageUrl: edittingPost!.selfie!.url,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                )
              : verticalSpaceRegular),
    ]);
  }
}
