import 'package:calificator/src/diagram/diagram_response.dart';
import 'package:calificator/src/diagram/prediction_response.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const fontSize = 16.0;
const radius = 100.0;
const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

List<PieChartSectionData> showingSections(DiagramResponse? diagramResponse) {
  if(diagramResponse==null){
    return List.empty();
  }else {
    List<PredictionResponse> values=diagramResponse.values;
    Map<int,int> map=sort(values.first);
    return List.generate(6, (i) {


      var length = values.first.caravanSize;
      int scoreLength= values.first.scores.length;
      switch (i) {
        case 0:
          return createSection(map[0]!*100/length,Colors.blue);
        case 1:
          return createSection(map[1]!*100/length,Colors.orange);
        case 2:
          return createSection(map[2]!*100/length,Colors.purple);
        case 3:
          return createSection(map[3]!*100/length,Colors.green);
        case 4:
          return createSection(map[4]!*100/length,Colors.red);
        case 5:
          return createSection((length-scoreLength)*100/length,Colors.grey);
        default:

          throw Error();
      }
    });
  }
}

PieChartSectionData createSection(double value,MaterialColor color) {
  return PieChartSectionData(
          color: color,
          value: value,
          title: getPercentage(value),
          radius: 100,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );
}

String getPercentage(double value){
  String valueToString=value.toStringAsFixed(2);
  if(decimals(value)>2) {
    valueToString+="~";
  }
  return valueToString+ '%';
}

int decimals(double value){
  var decimals=0;
  var split = value.toString().split('.');
  if(split.length>1) {
    decimals = split[1].length;
  }
  return decimals;
}
Map<int, int> sort(PredictionResponse values) {

  List<double> numbers= values.scores.map((e) => e.value).toList();
  Map<int, int> groupedMap = {};

  groupedMap.putIfAbsent(0, ()=> 0);
  groupedMap.putIfAbsent(1, ()=> 0);
  groupedMap.putIfAbsent(2, ()=> 0);
  groupedMap.putIfAbsent(3, ()=> 0);
  groupedMap.putIfAbsent(4, ()=> 0);

  numbers.forEach((number) {
    int range = number.floor();
    if(range != -1) {
      groupedMap[range] = (groupedMap[range]! + 1);
    }

  });



  return groupedMap;
}