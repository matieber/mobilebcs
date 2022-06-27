import 'package:cached_network_image/cached_network_image.dart';
import 'package:mercadosaludlib/mercadosalud.dart';
import 'package:flutter/material.dart';

class DoctorItem extends StatelessWidget {
  final FavouriteDoctor? doctor;
  final Function? onDeleteItem;
  const DoctorItem({
    Key? key,
    this.doctor,
    this.onDeleteItem,
  }) : super(key: key);

  Widget build_orig(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${doctor!.tituloCortesia} ${doctor!.fullName!}'),
              ],
            ),
          )),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (onDeleteItem != null) {
                onDeleteItem!();
              }
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(blurRadius: 8, color: Colors.grey[200]!, spreadRadius: 3)
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading:
                          Icon(Icons.medical_services_outlined, size: 40.0),
                      title: Text(
                        "${doctor!.tituloCortesia!} ${doctor!.fullName!}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        doctor!.especialidad!,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_sharp, size: 40.0),
                      //isThreeLine: true,
                    ),
                  ],
                ),
              )),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  if (onDeleteItem != null) {
                    onDeleteItem!();
                  }
                },
              ),
            ],
          )),
    );
  }
}
