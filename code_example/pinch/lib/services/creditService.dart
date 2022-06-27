import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class CreditUpdater {

  StreamController<Credit> cc;

  CreditUpdater(){
    cc = StreamController.broadcast();
  }

  get stream => cc.stream;

  Future<Credit> fetchCredit() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var queryParams = {
      'email': preferences.get('email'),
    };

    String queryString = Uri(queryParameters : queryParams).query;
    var requestURL = AppURLConstants.domain + AppURLConstants.creditURL + '?' +
                     queryString;
    var response = await http.get(requestURL);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return Credit.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to get credit');
    }
  }

  pollCredit() async{
    if (cc != null) {
      while (cc.hasListener) {
        await Future.delayed(Duration(seconds:ThresholdValues.poolCreditSecInterval));
        fetchCredit().then((value) => cc.add(value));
      }
    }
  }

}

class Credit {
    //variables to differentiate credit earned through watching advertising
    //from credit bought with some of the available payments forms
    final num boughtCredit;
    final num earnedCredit;

    Credit({this.boughtCredit, this.earnedCredit});

    factory Credit.fromJson(Map<String, dynamic> json) {
      return Credit(
        boughtCredit: json['bought'],
        earnedCredit: json['earned'],
      );
    }

}