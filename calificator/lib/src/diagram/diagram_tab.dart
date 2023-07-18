
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../ui_model/dropdown.dart';
import '../user/user.dart';
import '../viewer/viewer_stomp_client.dart';
import 'diagram_client.dart';
import 'diagram_response.dart';
import 'diagrams.dart';
import 'indicator.dart';

class DiagramViewerTab extends StatefulWidget {

  final DiagramClientHttp _diagramClientHttp;
  bool first=false;

   DiagramViewerTab(Key key) : _diagramClientHttp = DiagramClientHttp(),super(key: key);

  @override
  State<DiagramViewerTab> createState() => DiagramViewerTabState();



}

class DiagramViewerTabState extends State<DiagramViewerTab> {

  bool first=false;

  CustomDropdownButton? customDropdownButton;
  var pieChart;
  String title="";
  DiagramResponse? diagramResponse;
  String caravanSize="";
  String date="";

  @override
  Widget build(BuildContext context) {
    customDropdownButton ??= CustomDropdownButton([
      CustomDropdownText("CURRENT_QUALIFICATION", "Sessión en curso"),
      CustomDropdownText("LAST_QUALIFICATION", "Última sesión finalizada")],
        setDiagram);
  setDiagram();
    return Column(
      children: [
        customDropdownButton!,
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,decoration: TextDecoration.underline)),
        const SizedBox(height: 5),
        Text(caravanSize),
        Text(date),
        const SizedBox(height: 40),
        buildDiagramBody()
      ],
    );
  }

  AspectRatio buildDiagramBody() {
    pieChart = buildPieChart();
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 100,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 100,
              child: pieChart,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildIndicator(Colors.blue,'0 a 0.99'),
              buildSizedBox(),
              buildIndicator(Colors.orange, '1 a 1.99',),
              buildSizedBox(),
              buildIndicator(Colors.purple, '2 a 2.99'),
              buildIndicator(Colors.purple, '2 a 2.99'),
              buildSizedBox(),
              buildIndicator( Colors.green, '3 a 3.99'),
              buildSizedBox(),
              buildIndicator(Colors.red, '4 a 5'),
              buildSizedBox(),
              buildIndicator(Colors.grey, 'Sin valor'),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  PieChart buildPieChart() {
    return PieChart(
      PieChartData(
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: 0,
        sections: showingSections(diagramResponse),
      ),
    );
  }

  Indicator buildIndicator(Color color,String text) {
    return Indicator(
      color: color,
      text: text,
      isSquare: true,
    );
  }


  SizedBox buildSizedBox() {
    return const SizedBox(
      height: 5,
    );
  }

  void setDiagram() {
    if(customDropdownButton!=null) {
      widget._diagramClientHttp.getCurrentPrediction(context,
          customDropdownButton!.getValue()).then((currentDiagram) =>
          setState(() {
            diagramResponse = currentDiagram;
            buildPieChart();
            title=buildTitle(diagramResponse);
            caravanSize=buildCaravanSize(diagramResponse);
            date=buildDate(diagramResponse);
          })
      );
    }
  }

  String buildTitle(DiagramResponse? diagramResponse){
    String title="";
    // ignore: unnecessary_null_comparison
    if(diagramResponse!=null && diagramResponse.values!=null && diagramResponse.values.first!=null && diagramResponse.values.first.qualificationSession!=null){
      title="Sesión de calificación Nº "+diagramResponse.values.first.qualificationSession!.toString();
    }
    return title;
  }

  String buildCaravanSize(DiagramResponse? diagramResponse) {
    String caravanSize="";
    // ignore: unnecessary_null_comparison
    if(diagramResponse!=null && diagramResponse.values!=null && diagramResponse.values.first!=null && diagramResponse.values.first.caravanSize!=null){
      caravanSize="Total º "+diagramResponse.values.first.caravanSize!.toString();
    }
    return caravanSize;
  }

  String buildDate(DiagramResponse? diagramResponse) {
    String date="";
    // ignore: unnecessary_null_comparison
    if(diagramResponse!=null && diagramResponse.values!=null && diagramResponse.values.first!=null && diagramResponse.values.first.sessionStartDate!=null){
      date+="Desde º "+diagramResponse.values.first.sessionStartDate!.toString()+" ";
    }
    if(diagramResponse!=null && diagramResponse.values!=null && diagramResponse.values.first!=null && diagramResponse.values.first.sessionEndDate!=null){
      date+="hasta º "+diagramResponse.values.first.sessionEndDate!.toString();
    }
    return date;
  }

}