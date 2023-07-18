import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'caravan_response.dart';

class CaravanLineChart extends StatefulWidget {

  final CaravanInfoResponse? caravans;
  final List<int> _qualifications;
  CaravanLineChart(this.caravans,{key}): _qualifications=getQualifications(caravans);

  @override
  State<CaravanLineChart> createState() => _CaravanLineChartState();

  static List<int> getQualifications(CaravanInfoResponse? caravans) {
    List<int> list=<int>[];
    if(caravans!=null){
      for(CaravanQualificationResponse caravanQualificationResponse in caravans.list){
        list.add(caravanQualificationResponse.qualificationSessionId);
      }
    }
    return list;
  }
}

class _CaravanLineChartState extends State<CaravanLineChart> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    if(widget.caravans==null) {
      print("caravana esta vacia");
      return Container();
    }if(widget.caravans!.list.length<=1){
      return const Text("No hay historial de caravanas");
    }else {
      return Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.70,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 34,
                bottom: 102,
              ),
              child: LineChart(
                 mainData(),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );


    int qualificationSessionId = value.toInt();
    String text="";
    if(widget._qualifications.contains(qualificationSessionId)){
      text="N"+qualificationSessionId.toString();
    }
    return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text,style: style),
    );

  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text=value.toInt().toString();

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    double weight = 5;
    double qualificationSize = widget.caravans!.list.length.toDouble();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.green,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.green,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets
          ),
          axisNameWidget: const Text("Número de calificación",style: TextStyle(fontWeight: FontWeight.bold))
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 22,
          ),
            axisNameWidget: const Text("             Peso",style: TextStyle(fontWeight: FontWeight.bold)),

        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: qualificationSize+2,
      minY: 0,
      maxY: weight,
      lineBarsData: [
        LineChartBarData(
          spots: spots(),
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> spots() {
    var list = <FlSpot>[];
    for (var element in widget.caravans!.list) {
      print("id " + element.qualificationSessionId.toString() + " score " +
          element.score.toString());
      list.add(caravanScoreValue(
          element.qualificationSessionId.toDouble(), element.score));
    }


    //list.add(caravanScoreValue(1,3));
    //list.add(caravanScoreValue(2, 2));
    return list;
  }

  FlSpot caravanScoreValue(double x,double y) {
    return FlSpot(x, y);
  }

}