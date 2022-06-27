import 'package:apinch/services/creditService.dart';
import 'package:apinch/tabs/adverts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

import 'package:apinch/locator_service.dart' as di;

class CreditPage extends StatefulWidget {
  final VoidCallback goToAdvertsPage;

  CreditPage({Key key, this.goToAdvertsPage}) : super(key: key);

  @override
  _CreditPageState createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {

  @override
  void setState(fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).backgroundColor,
                child: FutureBuilder<Credit>(
                    future: di.sl<CreditUpdater>().fetchCredit(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');

                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text(
                            CreditPageMessages.noServerResponse,
                            style: Theme.of(context).textTheme.bodyText1,
                          );
                          break;
                        case ConnectionState.active:
                          return buildCreditInfo(snapshot.data);
                          break;
                        case ConnectionState.done:
                          return buildCreditInfo(snapshot.data);
                          break;
                        default:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                      }
                    }),
              ),
              SizedBox(
                height: 70,
              ),
              SizedBox(
                height: 12,
              ),
              buildBottomButtonRow(context),
            ]));
  }

  Widget buildBottomButtonRow(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
              SizedBox(
            height: 44.0,
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                CreditFieldNames.comprarActionButton,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 44.0,
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Text(
                CreditFieldNames.verPublicidadActionButton,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              onPressed: () {
                setState(() {widget.goToAdvertsPage();});
              },
            ),
          ),
        ],
    );
  }

  Widget buildCreditInfo(Credit data) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        color: Theme.of(context).backgroundColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: 70,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CreditPageMessages.availableCreditMessage,
                      style: TextStyle(color: Colors.white, fontSize: 30.0),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(children: <Widget>[
                      Text(
                        '${data.boughtCredit}',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 40.0),
                      ),
                      Text('${CreditPageMessages.boughtCreditLabel}',
                          style: Theme.of(context).textTheme.bodyText1),
                    ])),
              ),
              SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(children: <Widget>[
                      Text('${data.earnedCredit}',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 40.0)),
                      Text('${CreditPageMessages.earnedCreditLabel}',
                          style: Theme.of(context).textTheme.bodyText1),
                    ]),
                  )),
            ]));
  }
}
