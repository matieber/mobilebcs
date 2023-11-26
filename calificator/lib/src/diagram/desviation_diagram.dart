
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'deviation/deviation_client.dart';



  final Color line1Color=Colors.black;
  final Color line2Color=Colors.green;
  final Color betweenColor=Colors.green.withOpacity(0.5);

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    String text=value.toStringAsFixed(0);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value.toStringAsFixed(1)}',
        style: style,
      ),
    );
  }

  Widget createDeviationDiagram(List<QualifierSessionAverageResponse> dispersion) {
    return AspectRatio(
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 18,
          top: 10,
          bottom: 4,
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            lineBarsData: [
              negativeDeviation(dispersion),
              average(dispersion),
              positiveDeviation(dispersion),
            ],
            betweenBarsData: [
              BetweenBarsData(
                fromIndex: 0,
                toIndex: 1,
                color: betweenColor,
              ),
              BetweenBarsData(
                fromIndex: 1,
                toIndex: 2,
                color: betweenColor,
              )
            ],
            minY: 0,
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: leftTitleWidgets,
                  interval: 1,
                  reservedSize: 36,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (double value) {
                return value == 1 || value == 2 || value == 3 || value == 4 || value == 5;
              },
            ),
          ),
        ),
      ),
    );
  }



  LineChartBarData average(List<QualifierSessionAverageResponse> list) {
    List<FlSpot> spots2 = [];

    for(QualifierSessionAverageResponse qualifierSessionAverageResponse in list){
      spots2.add(FlSpot(qualifierSessionAverageResponse.qualificationSession.toDouble(),qualifierSessionAverageResponse.average));
    }
    return LineChartBarData(
      spots: spots2,
      isCurved: true,
      barWidth: 2,
      color: line2Color,
      dotData: FlDotData(
        show: true,
      ),
    );
  }

  LineChartBarData negativeDeviation(List<QualifierSessionAverageResponse> list ) {

    List<FlSpot> spots2 = [];

    for(QualifierSessionAverageResponse qualifierSessionAverageResponse in list){
      spots2.add(FlSpot(qualifierSessionAverageResponse.qualificationSession.toDouble(),qualifierSessionAverageResponse.average-qualifierSessionAverageResponse.stardardDeviation));
    }
    return LineChartBarData(
              spots: spots2,
              isCurved: true,
              barWidth: 2,
              color: line1Color,
              dotData: FlDotData(
                show: false,
              ),
            );
  }

LineChartBarData positiveDeviation(List<QualifierSessionAverageResponse> list ) {

  List<FlSpot> spots2 = [];

  for(QualifierSessionAverageResponse qualifierSessionAverageResponse in list){
    spots2.add(FlSpot(qualifierSessionAverageResponse.qualificationSession.toDouble(),qualifierSessionAverageResponse.average+qualifierSessionAverageResponse.stardardDeviation));
  }
  return LineChartBarData(
    spots: spots2,
    isCurved: true,
    barWidth: 2,
    color: line1Color,
    dotData: FlDotData(
      show: false,
    ),
  );
}