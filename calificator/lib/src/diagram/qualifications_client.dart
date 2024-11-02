import 'dart:convert';
import 'dart:async';
import 'package:calificator/src/diagram/qualifications_response.dart';
import 'package:calificator/src/settings/properties.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class QualificationsClient  {


  Future<QualificationsResponse?> getQualifications(BuildContext context) async{

    return Properties.getHttpServerUrl(context).then((_serverUrl) async {
      String endpointUrl = _serverUrl + "/qualifications/DEFAULT";
      Uri uri = Uri.parse(endpointUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print(responseBody);
        return QualificationsResponse.fromJson(responseBody);
      } else {
        if (response.statusCode == 204) {
          return null;
        }
      }
    });
  }


}