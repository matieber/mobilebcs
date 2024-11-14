import 'package:calificator/src/viewer/viewer_page_main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'caravan_response.dart';

class CaravanLineChart extends StatefulWidget {

  GlobalKey<ViewerPageMainState> mainKey;
  CaravanLineChart(key,this.mainKey ): super(key: key);

  @override
  State<CaravanLineChart> createState() => CaravanLineChartState();


}

class CaravanLineChartState extends State<CaravanLineChart> {


  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  bool showAvg = false;

    setCaravanDiagram(String currentSetCode,CaravanInfoResponse? newCaravans) {
        List<String> list=<String>[];
        List<String> setCodes=<String>[];
        if(newCaravans!=null){
          if(newCaravans.list.isEmpty){
            setText("No hay historial de caravanas");
          }else{
            if(newCaravans.list.length==1 && newCaravans.list.first.setCode==currentSetCode){
              setText("No hay historial de caravanas");
            }else{
              setCaravans(newCaravans);
              for(CaravanQualificationResponse caravanQualificationResponse in widget.mainKey.currentState!.caravans!.list){
                list.add("N${caravanQualificationResponse.qualificationSessionId}");
                setCodes.add(caravanQualificationResponse.setCode);
              }
            }
          }
        }else{
          setText("No hay historial de caravanas");

        }

        setQualifications(list);


  }

    void setCaravans(CaravanInfoResponse newCaravans) {
      if(mounted){
        setState(() {
          widget.mainKey.currentState!.caravans=newCaravans;
        });
      }else{
        widget.mainKey.currentState!.caravans=newCaravans;
      }
    }

    void setQualifications(List<String> list) {
      if(mounted){
        setState(() {
          widget.mainKey.currentState!.qualifications=list;
        });
      }else{
        widget.mainKey.currentState!.qualifications=list;
      }

    }

    void setText(String text) {
      if(mounted) {
       setState(() {
         widget.mainKey.currentState!.text = text;
       });
      }else{
        widget.mainKey.currentState!.text = text;
      }
    }

  addNewSetCode(String newSetCode,double newScore){
        var viewerPageMainState = widget.mainKey.currentState;
        if(viewerPageMainState!.caravans!=null && viewerPageMainState.caravans!.list.isNotEmpty) {
          if(!viewerPageMainState.qualifications.contains("Actual")) {
            addCaravan(viewerPageMainState, newScore, newSetCode);
            addQualification(viewerPageMainState);
          }
        }

  }

  void addQualification(ViewerPageMainState viewerPageMainState) {

        if(mounted){
          setState(() {
            viewerPageMainState.qualifications.add("Actual");
          });
        }else{
          viewerPageMainState.qualifications.add("Actual");
        }

  }

  void addCaravan(ViewerPageMainState viewerPageMainState, double newScore, String newSetCode) {
    var caravanQualificationResponse = CaravanQualificationResponse(
        newScore, null, newSetCode);
    if(mounted){
      setState(() {
        viewerPageMainState.caravans!.list.add(caravanQualificationResponse);
      });
    }else{
      viewerPageMainState.caravans!.list.add(caravanQualificationResponse);
    }

  }

  @override
  Widget build(BuildContext context) {
      return  Column(
        children: [
          Stack(
          children: <Widget>[
          buildAspectRatio(),
        ],
        ),
          Text(widget.mainKey.currentState!.text),
        ],
      );
  }

  Widget buildAspectRatio() {
      if(widget.mainKey.currentState!.caravans!=null && widget.mainKey.currentState!.caravans!.list.length>1) {
        return AspectRatio(
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
        );
      }else{
        return Container();
      }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );


    String text="";
    int position = value.toInt();
    if(widget.mainKey.currentState!.qualifications.length>position) {
      text = widget.mainKey.currentState!.qualifications.elementAt(position);
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
    double qualificationSize = widget.mainKey.currentState!.caravans!=null? widget.mainKey.currentState!.caravans!.list.length.toDouble():0;
    double weight = widget.mainKey.currentState!.caravans!=null? 5:0;
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
    double x=0;
    if(widget.mainKey.currentState!.caravans!=null) {
      for (var element in widget.mainKey.currentState!.caravans!.list) {

        list.add(caravanScoreValue(x, element.score));
        x++;
      }
    }
    return list;
  }

  FlSpot caravanScoreValue(double x,double y) {
    return FlSpot(x, y);
  }

}